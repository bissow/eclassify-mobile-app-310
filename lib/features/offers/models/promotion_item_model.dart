class PromotionItemModel {
  final int id;
  final int promotionId;
  final int itemId;
  final String itemName;
  final String itemSlug;
  final String? itemImage;
  final double originalPrice;
  final double promotionalPrice;
  final String formattedOriginalPrice;
  final String formattedPromotionalPrice;
  final double discountValue;
  final String discountType; // percentage, flat
  final int stockQuantity;
  final int remainingStockQuantity;
  final DateTime? validUntil;
  final String status;
  final String? city;
  final String? promotionType;

  PromotionItemModel({
    required this.id,
    required this.promotionId,
    required this.itemId,
    required this.itemName,
    required this.itemSlug,
    this.itemImage,
    required this.originalPrice,
    required this.promotionalPrice,
    required this.formattedOriginalPrice,
    required this.formattedPromotionalPrice,
    required this.discountValue,
    required this.discountType,
    required this.stockQuantity,
    required this.remainingStockQuantity,
    this.validUntil,
    required this.status,
    this.city,
    this.promotionType,
  });

  factory PromotionItemModel.fromJson(Map<String, dynamic> json) {
    final rawItem = json['item'] is Map<String, dynamic>
        ? json['item'] as Map<String, dynamic>
        : (json['ad'] is Map<String, dynamic> ? json['ad'] as Map<String, dynamic> : json);

    final origPrice = double.tryParse(json['original_price']?.toString() ?? rawItem['price']?.toString() ?? rawItem['original_price']?.toString() ?? '0') ?? 0.0;
    final promoPrice = double.tryParse(json['promotional_price']?.toString() ?? rawItem['promotional_price']?.toString() ?? '0') ?? 0.0;
    final resolvedItemId = json['item_id'] is int
        ? json['item_id']
        : int.tryParse(json['item_id']?.toString() ?? '') ?? (rawItem['id'] is int ? rawItem['id'] : int.tryParse(rawItem['id']?.toString() ?? '') ?? 0);

    return PromotionItemModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      promotionId: json['promotion_id'] is int ? json['promotion_id'] : int.tryParse(json['promotion_id'].toString()) ?? 0,
      itemId: resolvedItemId,
      itemName: rawItem['name'] ?? json['item_name'] ?? json['translation']?['name'] ?? 'Offer Item',
      itemSlug: rawItem['slug'] ?? json['item_slug'] ?? '',
      itemImage: rawItem['image'] ?? json['item_image'] ?? '',
      originalPrice: origPrice,
      promotionalPrice: promoPrice,
      formattedOriginalPrice: json['formatted_original_price'] ?? '\$$origPrice',
      formattedPromotionalPrice: json['formatted_promotional_price'] ?? '\$$promoPrice',
      discountValue: double.tryParse(json['discount_value']?.toString() ?? '0') ?? 0.0,
      discountType: json['discount_type'] ?? 'percentage',
      stockQuantity: int.tryParse(json['stock_quantity']?.toString() ?? '1') ?? 1,
      remainingStockQuantity: int.tryParse(json['remaining_stock_quantity']?.toString() ?? '1') ?? 1,
      validUntil: json['valid_until'] != null ? DateTime.tryParse(json['valid_until'].toString()) : null,
      status: json['status'] ?? 'active',
      city: rawItem['city'] ?? json['city'],
      promotionType: json['promotion']?['promotion_type'] ?? json['promotion_type'] ?? 'flash_sale',
    );
  }

  int get claimedStock => (stockQuantity - remainingStockQuantity).clamp(0, stockQuantity);

  double get stockPercentage {
    if (stockQuantity <= 0) return 0.0;
    return (claimedStock / stockQuantity).clamp(0.0, 1.0);
  }

  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }
}
