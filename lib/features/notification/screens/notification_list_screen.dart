import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/notification/cubits/notification_list_cubit.dart';
import 'package:eClassify/features/notification/models/notification.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/ads/interstitial_ad_on_exit_mixin.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({this.id, super.key});

  final String? id;

  @override
  NotificationListScreenState createState() => NotificationListScreenState();

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;

    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (context) => NotificationListCubit(),
        child: NotificationListScreen(id: args?['notificationId'] as String?),
      ),
    );
  }
}

class NotificationListScreenState extends State<NotificationListScreen>
    with InterstitialAdOnExitMixin {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text("notifications".translate(context))),
      body: PaginatedListView<NotificationListCubit, Notification, void>(
          padding: context.bodyPadding(),
          itemBuilder: (context, notification) {
            return ListTile(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  Routes.notificationDetailsScreen,
                  arguments: {'notification': notification},
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
                side: BorderSide(color: context.colorScheme.outlineVariant),
              ),
              trailing: notification.image.isNullOrEmpty
                  ? null
                  : CustomImage(
                      src: notification.image ?? '',
                      size: Size.square(50),
                      radius: 11,
                    ),
              title: Text(notification.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    notification.description,
                    style: context.bodyMedium.withColor(context.mutedColor),
                    maxLines: 2,
                  ),
                  Text(
                    notification.date.format(),
                    style: context.bodySmall.withColor(context.mutedColor),
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, _) => 10.vGap,
        ),
    );
  }

  Widget buildNotificationShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.all(10),
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemCount: 20,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return SizedBox(
          height: 55,
          child: Row(
            spacing: 5,
            children: <Widget>[
              const CustomShimmer(width: 50, height: 50, borderRadius: 11),
              Column(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  CustomShimmer(height: 7, width: 200),
                  CustomShimmer(height: 7, width: 100),
                  CustomShimmer(height: 7, width: 150),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
