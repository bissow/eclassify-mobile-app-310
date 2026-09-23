import 'package:eClassify/features/notification/cubits/notification_detail_cubit.dart';
import 'package:eClassify/features/notification/models/notification.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationDetailsScreen extends StatefulWidget {
  const NotificationDetailsScreen({
    super.key,
    this.notification,
    this.notificationId,
  }) : assert(
         notification != null || notificationId != null,
         'Either notification or notificationId must be provided',
       );

  final Notification? notification;
  final int? notificationId;

  @override
  State<NotificationDetailsScreen> createState() =>
      _NotificationDetailsScreenState();

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => NotificationDetailsCubit(),
        child: NotificationDetailsScreen(
          notification: args?['notification'] as Notification?,
          notificationId: args?['notification_id'] as int?,
        ),
      ),
    );
  }
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.notificationId != null) {
      context.read<NotificationDetailsCubit>().getNotificationDetails(
        id: widget.notificationId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (widget.notification != null) {
      child = _NotificationDetails(notification: widget.notification!);
    } else {
      child = BlocBuilder<NotificationDetailsCubit, NotificationDetailsState>(
        builder: (context, state) {
          if (state is NotificationDetailsFailure) {
            return QErrorWidget(
              error: state.error,
              onRetry: () => context
                  .read<NotificationDetailsCubit>()
                  .getNotificationDetails(id: widget.notificationId!),
            );
          }

          if (state is NotificationDetailsSuccess) {
            return _NotificationDetails(notification: state.notification);
          }

          return Center(child: LoadingIndicator());
        },
      );
    }

    return AppScaffold(
      appBar: AppBar(title: Text('notification'.translate(context))),
      body: child,
    );
  }
}

class _NotificationDetails extends StatelessWidget {
  const _NotificationDetails({required this.notification});

  final Notification notification;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: context.bodyPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (notification.image.isNotNullAndNotEmpty)
            AspectRatio(
              aspectRatio: 2,
              child: CustomImage(src: notification.image, radius: 16),
            ),
          20.vGap,
          Text(notification.title, style: context.titleLarge),
          4.vGap,
          Text(
            notification.date.format(),
            style: context.labelMedium.withColor(context.mutedColor),
          ),
          12.vGap,
          Text(notification.description, style: context.bodyMedium),
        ],
      ),
    );
  }
}
