import 'package:eClassify/core/models/localized_string.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:flutter/foundation.dart';

enum SubscriptionPackageType {
  featuredAds('advertisement'),
  itemListing('item_listing'),
  promotional('promotional');

  const SubscriptionPackageType(this.label);

  final String label;

  static SubscriptionPackageType parse(String key) =>
      values.firstWhere(
        (element) => element.label == key,
        orElse: () => SubscriptionPackageType.itemListing,
      );
}

@immutable
class SubscriptionPackage {
  SubscriptionPackage.fromJson(Json json)
    : id = json['id'] as int,
      iosProductId = json['ios_product_id'] as String?,
      name = LocalizedString(
        canonical: json['name'] as String,
        translated: json['translated_name'] as String,
      ),
      discountedPrice = json['final_price'] as num,
      formattedDiscountedPrice = json['formatted_final_price'] as String,
      formattedPrice = json['formatted_price'] as String,
      price = json['price'] as num,
      discount = json['discount_in_percentage'] as num,
      hasUnlimitedDuration = (json['duration'] as num?) == null,
      listingDurationDays = json['listing_duration_days'].toString(),
      itemLimit = json['item_limit'] as String,
      icon = json['icon'] as String,
      description = json['description'] as String,
      keyPoints =
          (json['translated_key_points'] as List?)?.cast<String>() ?? [],
      categories = JsonHelper.parseList(
        json['categories_path'] as List?,
        (json) => json['translated_name'] as String? ?? json['name'] as String?,
      ).nonNulls.toList(),
      isPurchasedBefore = json['is_purchased_before'] as bool? ?? false,
      activePackages = JsonHelper.parseList(
        json['user_purchased_packages'] as List?,
        ActivePackage.fromJson,
      ),
      type = SubscriptionPackageType.parse(json['type'] as String),
      isGlobal = (json['is_global'] as int?) == 1,
      isVideoAdAllowed = (json['is_reel_allowed'] as int?) == 1,
      allowsPromotions = (json['allows_promotions'] == 1 || json['allows_promotions'] == true || json['type'] == 'promotional'),
      promotionItemLimit = json['promotion_item_limit'] as int?,
      allowsDailyBumpUp = (json['allows_daily_bump_up'] == 1 || json['allows_daily_bump_up'] == true),
      dailyBumpUpLimit = json['daily_bump_up_limit'] as int?,
      allowsTopAd = (json['allows_top_ad'] == 1 || json['allows_top_ad'] == true),
      topAdLimit = json['top_ad_limit'] as int?,
      allowsSpotlight = (json['allows_spotlight'] == 1 || json['allows_spotlight'] == true),
      spotlightLimit = json['spotlight_limit'] as int?;

  bool get hasUnlimitedItem => itemLimit == 'unlimited';

  bool get isListingDurationUnlimited => listingDurationDays == 'unlimited';

  bool get isFree => discountedPrice == 0;

  bool get isPurchasable => !isFree || !isPurchasedBefore;

  bool get isActive => activePackages.isNotEmpty;

  final int id;
  final String? iosProductId;
  final LocalizedString name;
  final num discountedPrice;
  final String formattedDiscountedPrice;
  final num discount;
  final String formattedPrice;
  final num price;
  final bool hasUnlimitedDuration;
  final String listingDurationDays;
  final String itemLimit;
  final String icon;
  final String description;
  final List<String> keyPoints;
  final List<String> categories;
  final bool isPurchasedBefore;
  final List<ActivePackage> activePackages;
  final SubscriptionPackageType type;
  final bool isGlobal;
  final bool isVideoAdAllowed;
  final bool allowsPromotions;
  final int? promotionItemLimit;
  final bool allowsDailyBumpUp;
  final int? dailyBumpUpLimit;
  final bool allowsTopAd;
  final int? topAdLimit;
  final bool allowsSpotlight;
  final int? spotlightLimit;

  @override
  bool operator ==(Object other) =>
      other is SubscriptionPackage && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ActivePackage {
  ActivePackage.fromJson(Json json)
    : id = json['id'] as int,
      packageId = json['package_id'] as int,
      start = DateTime.parse(json['start_date'] as String),
      end = DateTime.tryParse(json['end_date'] as String? ?? ''),
      // Using toString here because of following condition
      // Unlimited Items => 'unlimited' or null
      // Fixed Items => int or "{int}"
      itemLimit = int.tryParse(json['item_limit'].toString()),
      remainingItemLimit = int.tryParse(
        json['remaining_item_limit'].toString(),
      ),
      usedLimit = int.tryParse(json['used_limit'].toString());

  final int id;
  final int packageId;
  final DateTime start;
  final DateTime? end;
  final int? itemLimit;
  final int? remainingItemLimit;
  final int? usedLimit;
}
