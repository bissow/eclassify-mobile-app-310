import 'dart:math';

import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/features/followers/repository/follow_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FollowUserListType { followers, following }

sealed class FollowUsersListState {}

class FollowUsersListInitial extends FollowUsersListState {}

class FollowUsersListLoading extends FollowUsersListState {}

class FollowUsersListSuccess extends FollowUsersListState {
  FollowUsersListSuccess({required this.users, required this.totalCount});

  final List<UserPreview> users;
  final int totalCount;
}

class FollowUsersListFailure extends FollowUsersListState {
  FollowUsersListFailure({required this.error});

  final Object error;
}

sealed class FollowUsersListCubit extends Cubit<FollowUsersListState>
    with SessionScoped {
  FollowUsersListCubit(this.type, [this.userId])
    : super(FollowUsersListInitial());
  final FollowUserListType type;
  final int? userId;

  int page = 1;
  bool hasMore = true;

  @override
  void clearSessionState() {
    page = 1;
    hasMore = true;
    emit(FollowUsersListInitial());
  }

  Future<void> getUsers() async {
    try {
      emit(FollowUsersListLoading());

      final response = await FollowRepository.instance.getFollowUsers(
        type: type,
        userId: userId,
      );

      final followers = response['users'] as List<UserPreview>;
      hasMore = response['has_more'] as bool;

      final followersCount = response['total_count'] as int;

      emit(
        FollowUsersListSuccess(users: followers, totalCount: followersCount),
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(FollowUsersListFailure(error: e));
    }
  }

  Future<void> getMoreUsers() async {
    try {
      final response = await FollowRepository.instance.getFollowUsers(
        type: type,
        userId: userId,
        page: page + 1,
      );

      final followers = response['users'] as List<UserPreview>;
      final followersCount = response['total_count'] as int;

      emit(
        FollowUsersListSuccess(users: followers, totalCount: followersCount),
      );
      hasMore = response['has_more'] as bool;
      if (hasMore) ++page;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(FollowUsersListFailure(error: e));
    }
  }

  void addUser(UserPreview user) {
    if (state is! FollowUsersListSuccess) return;
    final successState = state as FollowUsersListSuccess;
    emit(
      FollowUsersListSuccess(
        users: [user, ...successState.users],
        totalCount: successState.totalCount + 1,
      ),
    );
  }

  void removeUser(int userId) {
    if (state is! FollowUsersListSuccess) return;
    final successState = state as FollowUsersListSuccess;
    emit(
      FollowUsersListSuccess(
        users: successState.users.where((u) => u.id != userId).toList(),
        totalCount: max(0, successState.totalCount - 1),
      ),
    );
  }
}

final class FollowersListCubit extends FollowUsersListCubit {
  FollowersListCubit([int? userId])
    : super(FollowUserListType.followers, userId);
}

final class FollowingListCubit extends FollowUsersListCubit {
  FollowingListCubit([int? userId])
    : super(FollowUserListType.following, userId);

  // Keep track of the users that have been removed from the list in the current session
  // to sync UI accurately
  final List<int> removedUsers = List.empty(growable: true);

  @override
  void clearSessionState() {
    removedUsers.clear();
    super.clearSessionState();
  }

  @override
  void addUser(UserPreview user) {
    super.addUser(user);
    removedUsers.remove(user.id);
  }

  @override
  void removeUser(int userId) {
    super.removeUser(userId);
    removedUsers.add(userId);
  }

  void increaseTotalCount() {
    if (state is! FollowUsersListSuccess) return;
    final successState = state as FollowUsersListSuccess;
    emit(
      FollowUsersListSuccess(
        users: successState.users,
        totalCount: successState.totalCount + 1,
      ),
    );
  }

  void decreaseTotalCount() {
    if (state is! FollowUsersListSuccess) return;
    final successState = state as FollowUsersListSuccess;
    emit(
      FollowUsersListSuccess(
        users: successState.users,
        totalCount: max(0, successState.totalCount - 1),
      ),
    );
  }
}
