import 'package:eClassify/features/notification/models/notification.dart';
import 'package:eClassify/features/notification/repository/notification_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NotificationDetailsState {}

class NotificationDetailsInitial extends NotificationDetailsState {}

class NotificationDetailsLoading extends NotificationDetailsState {}

class NotificationDetailsSuccess extends NotificationDetailsState {
  NotificationDetailsSuccess({required this.notification});

  final Notification notification;
}

class NotificationDetailsFailure extends NotificationDetailsState {
  NotificationDetailsFailure({required this.error});

  final Object error;
}

class NotificationDetailsCubit extends Cubit<NotificationDetailsState> {
  NotificationDetailsCubit() : super(NotificationDetailsInitial());

  Future<void> getNotificationDetails({required int id}) async {
    try {
      emit(NotificationDetailsLoading());

      final notification = await NotificationRepository.instance
          .getNotificationById(id: id);

      emit(NotificationDetailsSuccess(notification: notification));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(NotificationDetailsFailure(error: e));
    }
  }
}
