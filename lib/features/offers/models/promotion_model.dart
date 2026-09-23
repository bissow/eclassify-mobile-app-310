class PromotionModel {
  final int id;
  final int? campaignId;
  final String title;
  final String slug;
  final String? description;
  final String promotionType; // flash_sale, clearance_sale, deal_of_the_day, custom
  final String? bannerImage;
  final String discountType; // percentage, flat
  final double discount;
  final DateTime startDate;
  final DateTime endDate;
  final String? startTime;
  final String? endTime;
  final bool isCountdownEnabled;
  final String status;
  final int itemsCount;

  PromotionModel({
    required this.id,
    this.campaignId,
    required this.title,
    required this.slug,
    this.description,
    required this.promotionType,
    this.bannerImage,
    required this.discountType,
    required this.discount,
    required this.startDate,
    required this.endDate,
    this.startTime,
    this.endTime,
    required this.isCountdownEnabled,
    required this.status,
    required this.itemsCount,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      campaignId: json['campaign_id'] != null ? int.tryParse(json['campaign_id'].toString()) : null,
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'],
      promotionType: json['promotion_type'] ?? 'flash_sale',
      bannerImage: json['banner_image'],
      discountType: json['discount_type'] ?? 'percentage',
      discount: json['discount'] != null ? double.tryParse(json['discount'].toString()) ?? 0.0 : 0.0,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      startTime: json['start_time'],
      endTime: json['end_time'],
      isCountdownEnabled: json['is_countdown_enabled'] == 1 || json['is_countdown_enabled'] == true,
      status: json['status'] ?? 'active',
      itemsCount: json['items_count'] != null ? int.tryParse(json['items_count'].toString()) ?? 0 : 0,
    );
  }

  bool get isFlashSale => promotionType == 'flash_sale';
  bool get isDealOfTheDay => promotionType == 'deal_of_the_day';
  bool get isClearanceSale => promotionType == 'clearance_sale';
}
