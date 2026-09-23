import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/profile/models/menu_item.dart';
import 'package:eClassify/features/profile/models/menu_item_action.dart';
import 'package:eClassify/features/profile/screens/widgets/menu_item_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:eClassify/core/constants/app_icons.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const HelpAndSupportScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      MenuItem(
        icon: AppIcons.question,
        title: 'faqs',
        showTrailing: true,
        action: ScreenPushAction(route: Routes.faqsScreen),
      ),
      MenuItem(
        icon: AppIcons.phone,
        title: 'contactUs',
        showTrailing: true,
        action: ScreenPushAction(route: Routes.contactUs),
      ),
    ];

    return AppScaffold(
      appBar: AppBar(title: Text('helpAndSupport'.translate(context))),
      body: Padding(
        padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
        child: Column(
          spacing: 12,
          children: items.map((item) {
            return MenuItemWidget(
              item: item,
              tileColor: context.colorScheme.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(12),
              ),
              contentPadding: EdgeInsets.all(12),
            );
          }).toList(),
        ),
      ),
    );
  }
}
