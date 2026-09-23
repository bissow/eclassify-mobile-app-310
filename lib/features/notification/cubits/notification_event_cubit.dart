import 'dart:async';
import 'dart:developer';
import 'package:eClassify/features/notification/models/server_notification.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/features/notification/enums/notification_type.dart';
import 'package:eClassify/features/notification/helpers/notification_utility.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum NotificationMode { foreground, background, terminated }

abstract class NotificationEventState {
  NotificationEventState({
    required this.remoteMessage,
    required this.mode,
    required this.notification,
  });

  final RemoteMessage? remoteMessage;
  final NotificationMode? mode;
  final ServerNotification notification;
}

class NotificationEventInitial extends NotificationEventState {
  NotificationEventInitial()
    : super(
        remoteMessage: null,
        mode: null,
        notification: const UnknownNotification({}),
      );
}

class BackgroundNotificationReceived extends NotificationEventState {
  BackgroundNotificationReceived({
    required super.remoteMessage,
    required super.mode,
    required super.notification,
  });
}

class ForegroundNotificationReceived extends NotificationEventState {
  ForegroundNotificationReceived({
    required super.remoteMessage,
    required super.notification,
  }) : super(mode: NotificationMode.foreground);
}

class ForegroundNotificationActionReceived extends NotificationEventState {
  ForegroundNotificationActionReceived({
    required super.remoteMessage,
    required this.payload,
    required super.notification,
  }) : super(mode: null);
  final Map<String, String?> payload;
}

class NotificationEventCubit extends Cubit<NotificationEventState> {
  NotificationEventCubit() : super(NotificationEventInitial()) {
    _initializeNotification();
  }

  StreamSubscription<RemoteMessage>? _foregroundNotificationStream;

  Future<void> _initializeNotification() async {
    final permissionGiven =
        await NotificationUtility.initializeNotificationService(
          onForegroundNotificationTap: (payload) {
            final notification = _resolveNotification(
              Map<String, dynamic>.from(payload),
            );
            if (notification == null) return;
            emit(
              ForegroundNotificationActionReceived(
                remoteMessage: null,
                payload: payload,
                notification: notification,
              ),
            );
          },
        );

    if (permissionGiven) {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        final notification = _resolveNotification(
          message.data,
          preview: message.notification?.body,
        );
        if (notification == null) return;
        log('Notification Tap while in background state');
        emit(
          BackgroundNotificationReceived(
            remoteMessage: message,
            mode: NotificationMode.background,
            notification: notification,
          ),
        );
      });
      _foregroundNotificationStream = FirebaseMessaging.onMessage.listen((
        message,
      ) {
        final notification = _resolveNotification(
          message.data,
          preview: message.notification?.body,
        );
        if (notification == null) return;
        log('Foreground Notification Received');
        emit(
          ForegroundNotificationReceived(
            remoteMessage: message,
            notification: notification,
          ),
        );
      });
      final message = await FirebaseMessaging.instance.getInitialMessage();
      if (message != null) {
        final notification = _resolveNotification(
          message.data,
          preview: message.notification?.body,
        );
        if (notification != null) {
          emit(
            BackgroundNotificationReceived(
              remoteMessage: message,
              mode: NotificationMode.terminated,
              notification: notification,
            ),
          );
        }
      }
    }
  }

  /// Returns `null` when the notification shouldn't be surfaced at all —
  /// either the type is unrecognized, or it requires a session that isn't
  /// there (e.g. a stale push arriving after logout). Otherwise parses
  /// [data] into its typed [ServerNotification] eagerly, once, here.
  ServerNotification? _resolveNotification(
    Map<String, dynamic> data, {
    String? preview,
  }) {
    final type =
        NotificationType.parse(data['type'] as String? ?? '') ??
        NotificationType.unknown;
    if (type == NotificationType.unknown) return null;
    if (type.requiresAuth && !AppSession.isAuthenticated) return null;
    // The notification body is the server's per-type preview ("Sent a
    // photo", offer text, ...) — the inbox shows it as the last message.
    return ServerNotification.fromData(type, data, preview: preview);
  }

  @override
  Future<void> close() {
    _foregroundNotificationStream?.cancel();
    return super.close();
  }
}
