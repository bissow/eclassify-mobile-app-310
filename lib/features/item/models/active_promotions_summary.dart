import 'package:eClassify/core/utils/json_helper.dart';

class ActivePromotionsSummary {
  final bool hasActivePromotions;
  final bool isDailyBumped;
  final bool isTopAd;
  final bool isSpotlight;
  final List<ActiveSaleItem> sales;
  final List<ActiveBoostItem> boosts;

  const ActivePromotionsSummary({
    this.hasActivePromotions = false,
    this.isDailyBumped = false,
    this.isTopAd = false,
    this.isSpotlight = false,
    this.sales = const [],
    this.boosts = const [],
  });

  factory ActivePromotionsSummary.fromJson(Json? json) {
    if (json == null) return const ActivePromotionsSummary();
    final salesList = JsonHelper.parseList(
      json['sales'] as List?,
      ActiveSaleItem.fromJson,
    );
    final boostsList = JsonHelper.parseList(
      json['boosts'] as List?,
      ActiveBoostItem.fromJson,
    );
    return ActivePromotionsSummary(
      hasActivePromotions: json['has_active_promotions'] as bool? ?? (salesList.isNotEmpty || boostsList.isNotEmpty),
      isDailyBumped: json['is_daily_bumped'] as bool? ?? false,
      isTopAd: json['is_top_ad'] as bool? ?? false,
      isSpotlight: json['is_spotlight'] as bool? ?? false,
      sales: salesList,
      boosts: boostsList,
    );
  }
}

class ActiveSaleItem {
  final int id;
  final int? promotionId;
  final String? promotionTitle;
  final String? promotionType;
  final int? campaignId;
  final String? campaignTitle;
  final String? campaignSlug;
  final double promotionalPrice;
  final String? formattedPromotionalPrice;
  final String? formattedOriginalPrice;
  final double discountValue;
  final String? discountType;
  final dynamic discountPercentage;
  final int stockQuantity;
  final int remainingStockQuantity;
  final int claimedCount;
  final String? validUntil;
  final String? status;

  ActiveSaleItem({
    required this.id,
    this.promotionId,
    this.promotionTitle,
    this.promotionType,
    this.campaignId,
    this.campaignTitle,
    this.campaignSlug,
    this.promotionalPrice = 0.0,
    this.formattedPromotionalPrice,
    this.formattedOriginalPrice,
    this.discountValue = 0.0,
    this.discountType,
    this.discountPercentage,
    this.stockQuantity = 0,
    this.remainingStockQuantity = 0,
    this.claimedCount = 0,
    this.validUntil,
    this.status,
  });

  factory ActiveSaleItem.fromJson(Json json) {
    return ActiveSaleItem(
      id: json['id'] as int? ?? 0,
      promotionId: json['promotion_id'] as int?,
      promotionTitle: json['promotion_title'] as String?,
      promotionType: json['promotion_type'] as String?,
      campaignId: json['campaign_id'] as int?,
      campaignTitle: json['campaign_title'] as String?,
      campaignSlug: json['campaign_slug'] as String?,
      promotionalPrice: (json['promotional_price'] as num?)?.toDouble() ?? 0.0,
      formattedPromotionalPrice: json['formatted_promotional_price'] as String?,
      formattedOriginalPrice: json['formatted_original_price'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discount_type'] as String?,
      discountPercentage: json['discount_percentage'],
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      remainingStockQuantity: json['remaining_stock_quantity'] as int? ?? 0,
      claimedCount: json['claimed_count'] as int? ?? 0,
      validUntil: json['valid_until'] as String?,
      status: json['status'] as String?,
    );
  }
}

class ActiveBoostItem {
  final int id;
  final String? promotionType;
  final String? typeTitle;
  final String? startDate;
  final String? endDate;
  final String? lastBumpedAt;
  final String? status;
  final bool isActive;

  ActiveBoostItem({
    required this.id,
    this.promotionType,
    this.typeTitle,
    this.startDate,
    this.endDate,
    this.lastBumpedAt,
    this.status,
    this.isActive = true,
  });

  factory ActiveBoostItem.fromJson(Json json) {
    return ActiveBoostItem(
      id: json['id'] as int? ?? 0,
      promotionType: json['promotion_type'] as String?,
      typeTitle: json['type_title'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      lastBumpedAt: json['last_bumped_at'] as String?,
      status: json['status'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}
