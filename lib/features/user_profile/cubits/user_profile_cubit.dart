import 'dart:async';

import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/auth/auth_module.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Which operation produced a given state.
///
/// This cubit is registered globally, so a screen listening for the result of
/// its own update also receives results from unrelated fetches — HomeScreen
/// calls getUserProfile() on mount, for instance. Tagging the operation lets
/// each listener ignore work it did not start.
enum UserProfileOperation { fetch, update }

abstract class UserProfileState {}

class UserProfileInitial extends UserProfileState {}

/// Base for states produced by an actual operation, as opposed to the
/// initial/cleared state which has no operation to attribute.
abstract class UserProfileOperationState extends UserProfileState {
  UserProfileOperationState(this.operation);

  final UserProfileOperation operation;

  bool get isUpdate => operation == UserProfileOperation.update;

  bool get isFetch => operation == UserProfileOperation.fetch;
}

class UserProfileLoading extends UserProfileOperationState {
  UserProfileLoading(super.operation);
}

class UserProfileSuccess extends UserProfileOperationState {
  UserProfileSuccess(super.operation, {required this.user, this.message});

  final User user;
  final String? message;
}

class UserProfileFailure extends UserProfileOperationState {
  UserProfileFailure(super.operation, {required this.error});

  final Object? error;
}

class UserProfileCubit extends Cubit<UserProfileState> with SessionScoped {
  UserProfileCubit() : super(UserProfileInitial());

  @override
  void clearSessionState() => emit(UserProfileInitial());

  final _repository = AuthModule.instance.profileRepository;
  final _localSessionService = AuthModule.instance.localSessionService;

  Future<void> getUserProfile() async {
    try {
      emit(UserProfileLoading(UserProfileOperation.fetch));

      final result = await _repository.getUserProfile();
      await _localSessionService.saveLocalUser(result.user);

      emit(
        UserProfileSuccess(
          UserProfileOperation.fetch,
          user: result.user,
          message: result.message,
        ),
      );

      unawaited(_syncFcmToken(result.user));
    } on Exception catch (e, st) {
      Log.error('Failed to get user profile', e, st);
      emit(UserProfileFailure(UserProfileOperation.fetch, error: e));
    }
  }

  /// FCM tokens rotate and expire; the backend only learns a new one when
  /// we send it. get-user-info returns every token it holds, so if this
  /// device's current token isn't among them, push it via update-profile.
  /// Silent: no state is emitted, so profile listeners never see it as an
  /// update they started.
  Future<void> _syncFcmToken(User user) async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) return;
      if (user.fcmTokens?.contains(token) ?? false) return;

      Log.info('FCM token not registered on server, updating');
      final result = await _repository.updateUserProfile(
        user.copyWith(fcmId: token),
      );
      await _localSessionService.saveLocalUser(result.user);
    } on Exception catch (e, st) {
      Log.error('Failed to sync FCM token', e, st);
    }
  }

  Future<void> updateUserProfile(User user, {String? profileImagePath}) async {
    try {
      emit(UserProfileLoading(UserProfileOperation.update));

      final result = await _repository.updateUserProfile(
        user,
        profileImagePath: profileImagePath,
      );
      await _localSessionService.saveLocalUser(result.user);

      emit(
        UserProfileSuccess(
          UserProfileOperation.update,
          user: result.user,
          message: result.message,
        ),
      );
    } on Exception catch (e, st) {
      Log.error('Failed to update user profile', e, st);
      emit(UserProfileFailure(UserProfileOperation.update, error: e));
    }
  }
}
