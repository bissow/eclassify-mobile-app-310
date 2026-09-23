import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/models/company_details.dart';
import 'package:eClassify/features/profile/models/menu_item.dart';
import 'package:eClassify/features/profile/models/menu_item_action.dart';
import 'package:eClassify/features/profile/screens/widgets/menu_item_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const LegalInformationScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      MenuItem(
        icon: AppIcons.question,
        title: 'aboutUs',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.aboutUs,
        ),
      ),
      MenuItem(
        icon: AppIcons.shieldCheck,
        title: 'termsAndConditions',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.termsAndConditions,
        ),
      ),
      MenuItem(
        icon: AppIcons.note,
        title: 'privacyPolicy',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.privacyPolicy,
        ),
      ),
      MenuItem(
        icon: AppIcons.receipt,
        title: 'refundPolicy',
        showTrailing: true,
        action: ScreenPushAction(
          route: Routes.companyPage,
          args: CompanyPage.refundPolicy,
        ),
      ),
    ];

    return AppScaffold(
      appBar: AppBar(title: Text('legalInformation'.translate(context))),
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
