import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationHandler;
import 'package:eClassify/features/notification/enums/notification_type.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

typedef NotificationActionCallback =
    void Function(Map<String, String?> payload);

class NotificationUtility {
  static final _basicChannel = 'basic_channel';
  static final _chatChannel = 'chat_channel';

  static final AwesomeNotifications _awesomeInstance = AwesomeNotifications();

  static Completer<AuthorizationStatus> _notificationPermissionStatus =
      Completer<AuthorizationStatus>();

  static Completer<AuthorizationStatus> get notificationPermissionStatus =>
      _notificationPermissionStatus;

  static Map<String, dynamic>? _pendingNotificationPayload;

  static bool get hasPendingNotification => _pendingNotificationPayload != null;

  static Future<bool> _askNotificationPermission() async {
    final notificationSettings = await FirebaseMessaging.instance
        .requestPermission();
    return notificationSettings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        notificationSettings.authorizationStatus ==
            AuthorizationStatus.provisional;
  }

  static Future<bool> initializeNotificationService({
    required NotificationActionCallback onForegroundNotificationTap,
  }) async {
    final notificationSettings = await FirebaseMessaging.instance
        .getNotificationSettings();

    //check if the permission is given. If not, ask for the permission.
    //If still not granted, do not initialize anything related to notification
    final permissionGiven = switch (notificationSettings.authorizationStatus) {
      AuthorizationStatus.authorized => true,
      AuthorizationStatus.provisional => true,
      AuthorizationStatus.denied => await _askNotificationPermission(),
      AuthorizationStatus.notDetermined => await _askNotificationPermission(),
      AuthorizationStatus.deniedPermanently => false,
    };

    if (permissionGiven) {
      await _initializeAwesomeNotification(
        onForegroundNotificationTap: onForegroundNotificationTap,
      );
    }
    if (!_notificationPermissionStatus.isCompleted) {
      _notificationPermissionStatus.complete(
        notificationSettings.authorizationStatus,
      );
    }
    return permissionGiven;
  }

  static Future<void> _initializeAwesomeNotification({
    required NotificationActionCallback onForegroundNotificationTap,
  }) async {
    final hasInitialized = await _awesomeInstance.initialize(
      null,
      [
        NotificationChannel(
          channelKey: _basicChannel,
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel',
          importance: NotificationImportance.Max,
        ),
        NotificationChannel(
          channelKey: _chatChannel,
          channelName: 'Chat Notifications',
          channelDescription: 'Chat Notifications',
          importance: NotificationImportance.Max,
        ),
      ],
      channelGroups: [],
      debug: true,
    );
    if (!hasInitialized) {
      log('Awesome notifications was not initialized', name: 'NOTIFICATION');
      return;
    }

    _awesomeInstance.setListeners(
      onActionReceivedMethod: (receivedAction) async {
        if (receivedAction.payload != null) {
          onForegroundNotificationTap.call(receivedAction.payload!);
        }
      },
    );
  }

  static void createLocalNotification(RemoteMessage message) {
    if (Platform.isIOS) return;
    log('${message.data}', name: 'MESSAGE RECEIVED');

    final notificationType = NotificationType.parse(
      message.data['type'] as String? ?? '',
    );
    final isChat = notificationType == NotificationType.chat;

    final channel = isChat ? _chatChannel : _basicChannel;

    // Grouping (groupKey + MessagingGroup) makes Android manage an OS-level
    // group-summary notification. Only chat notifications actually need
    // that (multiple messages from the same conversation collapsing
    // together); every other type gets its own standalone notification.
    _awesomeInstance.createNotification(
      content: NotificationContent(
        id: DateTime.now().microsecondsSinceEpoch % 0x7FFFFFFF,
        channelKey: channel,
        title: message.notification?.title,
        body: message.notification?.body,
        groupKey: isChat ? message.data['item_id'] : null,
        bigPicture: message.data['image'] as String?,
        notificationLayout: message.data['image'] != null
            ? NotificationLayout.BigPicture
            : (isChat
                  ? NotificationLayout.MessagingGroup
                  : NotificationLayout.Default),
        payload: Map<String, String>.from(message.data),
      ),
    );
  }
}
