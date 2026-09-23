import 'package:eClassify/features/notification/models/notification.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class NotificationRepository {
  NotificationRepository._internal();

  static final NotificationRepository _instance =
      NotificationRepository._internal();

  static NotificationRepository get instance => _instance;

  Future<PaginatedResult<Notification>> fetchNotifications({
    required int page,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getNotificationList,
        queryParameters: {ApiParams.page: page},
      );

      final notifications = JsonHelper.parseList(
        response['data']['data'] as List?,
        Notification.fromJson,
      );
      final total = response['data']['total'] as int;

      return PaginatedResult(data: notifications, total: total);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<Notification> getNotificationById({required int id}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getNotificationList,
        queryParameters: {ApiParams.id: id},
      );

      return Notification.fromJson(response['data']);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
