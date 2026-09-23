import 'package:eClassify/features/notification/cubits/notification_event_cubit.dart';
import 'package:eClassify/features/notification/models/server_notification.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Screen-scoped reaction to a single [ServerNotification] variant.
///
/// Unlike `NotificationHandler` (global side effects that must fire
/// regardless of which screen is mounted — chat unread counts, offer
/// lists), this is for screens that only care about a notification while
/// they're actually on screen: e.g. a payment webhook notification
/// arriving while the user is looking at their active plans should
/// refresh that list, but there's no reason for that refresh to happen
/// anywhere else in the app.
///
/// [T] selects which variant to react to — [onNotification] only fires
/// when [NotificationEventState.notification] is a [T].
class ServerNotificationListener<T extends ServerNotification>
    extends StatelessWidget {
  const ServerNotificationListener({
    required this.onNotification,
    required this.child,
    super.key,
  });

  final void Function(BuildContext context, T notification) onNotification;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationEventCubit, NotificationEventState>(
      listenWhen: (_, state) => state.notification is T,
      listener: (context, state) {
        final notification = state.notification;
        if (notification is T) onNotification(context, notification);
      },
      child: child,
    );
  }
}
