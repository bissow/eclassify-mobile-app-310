class AdPromotionOptionsModel {
  final bool isVerified;
  final bool requiresVerification;
  final bool requiresPackage;
  final bool hasActivePackage;
  final bool hasQuota;
  final String? message;
  final bool canBump;
  final int bumpRemaining;
  final bool canTopAd;
  final int topAdRemaining;
  final bool canSpotlight;
  final int spotlightRemaining;
  final bool allowsPromotions;
  final int promotionItemRemaining;
  final String? verificationStatus;
  final bool isDailyBumpActive;
  final bool isTopAdActive;
  final bool isSpotlightActive;

  AdPromotionOptionsModel({
    this.isVerified = true,
    this.verificationStatus,
    this.requiresVerification = false,
    this.requiresPackage = false,
    this.hasActivePackage = true,
    this.hasQuota = true,
    this.message,
    required this.canBump,
    required this.bumpRemaining,
    required this.canTopAd,
    required this.topAdRemaining,
    required this.canSpotlight,
    required this.spotlightRemaining,
    required this.allowsPromotions,
    required this.promotionItemRemaining,
    this.isDailyBumpActive = false,
    this.isTopAdActive = false,
    this.isSpotlightActive = false,
  });

  factory AdPromotionOptionsModel.fromJson(Map<String, dynamic> json) {
    // Check if options array exists and extract individual option quotas if present
    int bumpRem = 0;
    int topAdRem = 0;
    int spotlightRem = 0;
    bool bumpActive = false;
    bool topAdActive = false;
    bool spotlightActive = false;

    if (json['options'] is List) {
      final opts = json['options'] as List;
      for (final opt in opts) {
        if (opt is Map) {
          final type = opt['type'];
          final quotaLeft = opt['quota_left'];
          final val = quotaLeft == 'unlimited' ? 9999 : (int.tryParse(quotaLeft?.toString() ?? '0') ?? 0);
          final isActive = opt['is_active'] == true || opt['is_active'] == 1;
          if (type == 'daily_bump_up') {
            bumpRem = val;
            bumpActive = isActive;
          }
          if (type == 'top_ad') {
            topAdRem = val;
            topAdActive = isActive;
          }
          if (type == 'spotlight') {
            spotlightRem = val;
            spotlightActive = isActive;
          }
        }
      }
    } else {
      bumpRem = int.tryParse(json['bump_remaining']?.toString() ?? '0') ?? 0;
      topAdRem = int.tryParse(json['top_ad_remaining']?.toString() ?? '0') ?? 0;
      spotlightRem = int.tryParse(json['spotlight_remaining']?.toString() ?? '0') ?? 0;
    }

    final isVerified = json['is_verified'] == null ? true : (json['is_verified'] == true || json['is_verified'] == 1);
    final reqVerification = json['requires_verification'] == true || json['requires_verification'] == 1 || !isVerified;
    final reqPackage = json['requires_package'] == true || json['requires_package'] == 1 || (isVerified && (bumpRem + topAdRem + spotlightRem <= 0));

    return AdPromotionOptionsModel(
      isVerified: isVerified,
      verificationStatus: json['verification_status']?.toString(),
      requiresVerification: reqVerification,
      requiresPackage: reqPackage,
      hasActivePackage: json['has_active_package'] == null ? true : (json['has_active_package'] == true || json['has_active_package'] == 1),
      hasQuota: (bumpRem + topAdRem + spotlightRem) > 0,
      message: json['message']?.toString(),
      canBump: isVerified && (json['can_bump'] == true || json['can_bump'] == 1 || bumpRem > 0),
      bumpRemaining: bumpRem,
      canTopAd: isVerified && (json['can_top_ad'] == true || json['can_top_ad'] == 1 || topAdRem > 0),
      topAdRemaining: topAdRem,
      canSpotlight: isVerified && (json['can_spotlight'] == true || json['can_spotlight'] == 1 || spotlightRem > 0),
      spotlightRemaining: spotlightRem,
      allowsPromotions: json['allows_promotions'] == true || json['allows_promotions'] == 1,
      promotionItemRemaining: int.tryParse(json['promotions_remaining']?.toString() ?? '0') ?? 0,
      isDailyBumpActive: bumpActive,
      isTopAdActive: topAdActive,
      isSpotlightActive: spotlightActive,
    );
  }
}
