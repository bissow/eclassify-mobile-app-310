import 'package:eClassify/core/utils/json_helper.dart';

class SellerPromotionsAnalyticsModel {
  final SellerPromotionsSummary summary;
  final Map<String, dynamic> breakdownByPromotionType;
  final Map<String, dynamic> breakdownByBoostType;

  SellerPromotionsAnalyticsModel({
    required this.summary,
    required this.breakdownByPromotionType,
    required this.breakdownByBoostType,
  });

  factory SellerPromotionsAnalyticsModel.fromJson(Json json) {
    return SellerPromotionsAnalyticsModel(
      summary: SellerPromotionsSummary.fromJson(json['summary'] as Json? ?? {}),
      breakdownByPromotionType: (json['breakdown_by_promotion_type'] as Map<String, dynamic>?) ?? {},
      breakdownByBoostType: (json['breakdown_by_boost_type'] as Map<String, dynamic>?) ?? {},
    );
  }
}

class SellerPromotionsSummary {
  final int activePromotionsCount;
  final int totalPromotedAds;
  final int totalPromotionUnitsSold;
  final double totalEstimatedPromotionRevenue;
  final double totalBuyerSavings;
  final int activeSalesCount;
  final int activeBoostsCount;
  final int activeCampaignsJoined;

  SellerPromotionsSummary({
    this.activePromotionsCount = 0,
    this.totalPromotedAds = 0,
    this.totalPromotionUnitsSold = 0,
    this.totalEstimatedPromotionRevenue = 0.0,
    this.totalBuyerSavings = 0.0,
    this.activeSalesCount = 0,
    this.activeBoostsCount = 0,
    this.activeCampaignsJoined = 0,
  });

  factory SellerPromotionsSummary.fromJson(Json json) {
    return SellerPromotionsSummary(
      activePromotionsCount: (json['active_promotions_count'] as num?)?.toInt() ?? 0,
      totalPromotedAds: (json['total_promoted_ads'] as num?)?.toInt() ?? 0,
      totalPromotionUnitsSold: (json['total_promotion_units_sold'] as num?)?.toInt() ?? 0,
      totalEstimatedPromotionRevenue: (json['total_estimated_promotion_revenue'] as num?)?.toDouble() ?? 0.0,
      totalBuyerSavings: (json['total_buyer_savings'] as num?)?.toDouble() ?? 0.0,
      activeSalesCount: (json['active_sales_count'] as num?)?.toInt() ?? 0,
      activeBoostsCount: (json['active_boosts_count'] as num?)?.toInt() ?? 0,
      activeCampaignsJoined: (json['active_campaigns_joined'] as num?)?.toInt() ?? 0,
    );
  }
}

class SellerPromotionHistoryItem {
  final String historyType;
  final int id;
  final int? itemId;
  final String itemName;
  final String? itemSlug;
  final String itemImage;
  final double regularPrice;
  final String? type;
  final String? typeTitle;
  final String? campaignTitle;
  final String? campaignSlug;
  final String? campaignBanner;
  final String? discountType;
  final double discountValue;
  final dynamic discountPercentage;
  final double promotionalPrice;
  final int stockQuantity;
  final int remainingStockQuantity;
  final int unitsClaimed;
  final dynamic claimPercentage;
  final double estimatedRevenue;
  final int activeDurationDays;
  final String? startDate;
  final String? endDate;
  final String? lastBumpedAt;
  final int views;
  final String status;
  final bool isActive;

  SellerPromotionHistoryItem({
    required this.historyType,
    required this.id,
    this.itemId,
    required this.itemName,
    this.itemSlug,
    required this.itemImage,
    this.regularPrice = 0.0,
    this.type,
    this.typeTitle,
    this.campaignTitle,
    this.campaignSlug,
    this.campaignBanner,
    this.discountType,
    this.discountValue = 0.0,
    this.discountPercentage,
    this.promotionalPrice = 0.0,
    this.stockQuantity = 0,
    this.remainingStockQuantity = 0,
    this.unitsClaimed = 0,
    this.claimPercentage = 0,
    this.estimatedRevenue = 0.0,
    this.activeDurationDays = 0,
    this.startDate,
    this.endDate,
    this.lastBumpedAt,
    this.views = 0,
    this.status = 'unknown',
    this.isActive = false,
  });

  factory SellerPromotionHistoryItem.fromJson(Json json) {
    return SellerPromotionHistoryItem(
      historyType: (json['record_type'] as String?) ?? (json['history_type'] as String? ?? 'sale'),
      id: json['id'] as int? ?? 0,
      itemId: json['item_id'] as int?,
      itemName: json['item_name'] as String? ?? '',
      itemSlug: (json['item_slug'] as String?) ?? (json['item'] is Map ? json['item']['slug'] as String? : null),
      itemImage: json['item_image'] as String? ?? '',
      regularPrice: (json['original_price'] as num?)?.toDouble() ?? ((json['regular_price'] as num?)?.toDouble() ?? 0.0),
      type: (json['promotion_type'] as String?) ?? (json['type'] as String?),
      typeTitle: (json['type_title'] as String?) ?? (json['promotion'] is Map ? json['promotion']['title'] as String? : null),
      campaignTitle: json['campaign_title'] as String? ?? (json['promotion'] is Map && json['promotion']['campaign'] is Map ? json['promotion']['campaign']['title'] as String? : null),
      campaignSlug: json['campaign_slug'] as String? ?? (json['promotion'] is Map && json['promotion']['campaign'] is Map ? json['promotion']['campaign']['slug'] as String? : null),
      campaignBanner: json['campaign_banner'] as String?,
      discountType: json['discount_type'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      discountPercentage: json['discount_percentage'],
      promotionalPrice: (json['promotional_price'] as num?)?.toDouble() ?? 0.0,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      remainingStockQuantity: (json['remaining_stock_quantity'] as num?)?.toInt() ?? 0,
      unitsClaimed: (json['claimed_units'] as num?)?.toInt() ?? ((json['units_claimed'] as num?)?.toInt() ?? 0),
      claimPercentage: json['claimed_percentage'] ?? (json['claim_percentage'] ?? 0),
      estimatedRevenue: (json['generated_revenue'] as num?)?.toDouble() ?? ((json['estimated_revenue'] as num?)?.toDouble() ?? 0.0),
      activeDurationDays: (json['days_active'] as num?)?.toInt() ?? ((json['active_duration_days'] as num?)?.toInt() ?? 0),
      startDate: json['start_date'] as String?,
      endDate: (json['valid_until'] as String?) ?? (json['end_date'] as String?),
      lastBumpedAt: json['last_bumped_at'] as String?,
      views: (json['views'] as num?)?.toInt() ?? ((json['clicks'] as num?)?.toInt() ?? 0),
      status: json['status'] as String? ?? 'unknown',
      isActive: (json['is_currently_active'] as bool?) ?? ((json['is_active'] as bool?) ?? false),
    );
  }
}
