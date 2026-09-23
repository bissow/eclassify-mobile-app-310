import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class FollowRepository {
  FollowRepository._internal();

  static final _instance = FollowRepository._internal();

  static FollowRepository get instance => _instance;

  Future<void> followUser({required int userId}) async {
    try {
      await Api.post(url: ApiEndpoints.followUser, parameter: {ApiParams.userId: userId});
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> unFollowUser({required int userId}) async {
    try {
      await Api.post(url: ApiEndpoints.unFollowUser, parameter: {ApiParams.userId: userId});
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Json> getFollowUsers({
    required FollowUserListType type,
    int? userId,
    int page = 1,
  }) async {
    try {
      final endpoint = switch (type) {
        FollowUserListType.followers => ApiEndpoints.followers,
        FollowUserListType.following => ApiEndpoints.following,
      };

      final response = await Api.get(
        url: endpoint,
        queryParameters: {ApiParams.userId: ?userId, ApiParams.page: page},
      );

      final users = JsonHelper.parseList(
        response['data']['data'] as List?,
        UserPreview.fromJson,
      );

      final hasMore = response['data']['per_page'] as int == users.length;
      final followersCount = response['data']['total'] as int;

      return {
        'users': users,
        'has_more': hasMore,
        'total_count': followersCount,
      };
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
