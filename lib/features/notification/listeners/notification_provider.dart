import 'dart:developer';

import 'package:eClassify/features/notification/cubits/notification_event_cubit.dart';
import 'package:eClassify/features/notification/models/server_notification.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/features/notification/helpers/notification_handler.dart';
import 'package:eClassify/features/notification/helpers/notification_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationProvider extends StatelessWidget {
  const NotificationProvider({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationEventCubit, NotificationEventState>(
      listener: (context, state) async {
        if (state is! ForegroundNotificationActionReceived &&
            state.mode != NotificationMode.terminated) {
          NotificationHandler.handleSideEffects(context, state.notification);
        }
        if (context.mounted) {
          if (state is BackgroundNotificationReceived) {
            NotificationHandler.handleNotification(context, state.notification);
          } else if (state is ForegroundNotificationReceived) {
            log(
              '${state.remoteMessage?.data}',
              name: 'Foreground Notification',
            );
            final notification = state.notification;

            if (notification is ChatNotification &&
                notification.chatUser.id == AppSession.activeChatId) {
              log(
                'Suppressed redundant notification for Chat ${notification.chatUser.id}',
              );
              return;
            }

            NotificationUtility.createLocalNotification(state.remoteMessage!);
          } else if (state is ForegroundNotificationActionReceived) {
            NotificationHandler.handleNotification(context, state.notification);
          }
        }
      },
      child: child,
    );
  }
}
