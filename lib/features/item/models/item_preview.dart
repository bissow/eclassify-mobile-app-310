import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/core/utils/json_helper.dart';

import 'package:eClassify/features/item/models/active_promotions_summary.dart';

class ItemPreview {
  ItemPreview({
    required this.id,
    required this.userId,
    required this.image,
    required this.price,
    required this.name,
    required this.address,
    required this.postedAt,
    this.isFeatured = false,
    this.isLiked = false,
    this.activePromotions,
  });

  ItemPreview.fromJson(Json json)
    : id = json['id'] as int,
      userId = json['user_id'] as int,
      image = json['image'] as String? ?? '',
      price =
          (json['formatted_price'] ?? json['formatted_salary_range'])
              as String?,
      name = json['translation']?['name'] as String,
      address = json['translation']?['address'] as String? ?? '',
      postedAt = DateTime.parse(json['published_at'] as String),
      isFeatured = json['is_feature'] as bool? ?? false,
      isLiked = json['is_liked'] as bool? ?? false,
      activePromotions = json['active_promotions'] != null
          ? ActivePromotionsSummary.fromJson(json['active_promotions'] as Json?)
          : null;

  final int id;
  final int userId;
  final String image;
  final String? price;
  final String name;
  final String address;
  final DateTime postedAt;
  final bool isFeatured;
  final bool isLiked;
  final ActivePromotionsSummary? activePromotions;

  ActiveSaleItem? get primaryActiveSale =>
      (activePromotions?.sales.isNotEmpty ?? false)
          ? activePromotions!.sales.first
          : null;

  bool get hasActiveSale => primaryActiveSale != null;

  bool get isSpotlight => activePromotions?.isSpotlight ?? false;

  bool get isTopAd => activePromotions?.isTopAd ?? false;
}

class MyItemPreview extends ItemPreview {
  MyItemPreview.fromJson(super.json)
    : type = AdItemType.fromName(json['item_type']),
      status = ItemStatus.parse(json['status'] as String),
      isEditedByAdmin = (json['is_edited_by_admin'] as int?) == 1,
      views = json['views'] as int? ?? 0,
      likes = json['likes'] as int? ?? 0,
      super.fromJson();

  final AdItemType type;
  final ItemStatus status;
  final bool isEditedByAdmin;
  final int views;
  final int likes;
}

