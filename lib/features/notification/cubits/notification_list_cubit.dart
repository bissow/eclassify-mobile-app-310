import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/notification/models/notification.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/notification/repository/notification_repository.dart';

class NotificationListCubit extends PaginatedCubit<Notification, void> {
  @override
  Future<PaginatedResult<Notification>> getPage(int page, {void params}) {
    return NotificationRepository.instance.fetchNotifications(page: page);
  }
}
