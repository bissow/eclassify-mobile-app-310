import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class NoPackageAvailableDialog {
  static void show(
    BuildContext context, {
    required SubscriptionPackageType type,
    AdItemType adType = AdItemType.regularAd,
    Category? category,
  }) {
    final contentText = switch ((type, category)) {
      (SubscriptionPackageType.featuredAds, _) =>
        'featureAdSubscriptionNotice'.translate(context),
      (SubscriptionPackageType.itemListing, final Category c) =>
        'categoryItemListingSubscriptionNotice'.translate(context, {
          'category_name': c.name.localized,
          'ad_type': adType.label.translate(context),
        }),
      (SubscriptionPackageType.itemListing, _) =>
        'itemListingSubscriptionNotice'.translate(context),
    };

    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'subscriptionRequired'.translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            contentText.translate(context),
            textAlign: TextAlign.center,
            style: context.bodyMedium,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          positiveButtonLabel: 'subscribe'.translate(context),
          onPositiveTapped: () {
            final routeConfig = switch ((type, category)) {
              (SubscriptionPackageType.featuredAds, _) => (
                route: Routes.subscriptionPackageScreen,
                args: null,
              ),
              (SubscriptionPackageType.itemListing, final Category c) => (
                route: Routes.subscriptionPackageScreen,
                args: {'category': c, 'show_category_selection': false},
              ),
              (SubscriptionPackageType.itemListing, _) => (
                route: Routes.subscriptionCategorySelectionScreen,
                args: null,
              ),
            };
            Navigator.of(
              context,
            ).popAndPushNamed(routeConfig.route, arguments: routeConfig.args);
          },
        );
      },
    );
  }
}
