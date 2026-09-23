import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/core/models/localized_string.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/custom_fields/enums/custom_field_type.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/item/models/product_video.dart';
import 'package:eClassify/features/item/models/active_promotions_summary.dart';
import 'package:eClassify/features/seller/models/seller.dart';

typedef ItemImage = ({int? id, String url, bool isDefault});

/// `is_default` marks the entry in `gallery_images` that mirrors the item's
/// main image. The API sends it as 1/0, so bools and numeric strings are
/// accepted too rather than assuming one encoding.
bool _parseIsDefault(dynamic value) => switch (value) {
  final bool value => value,
  final num value => value != 0,
  final String value => value == '1' || value.toLowerCase() == 'true',
  _ => false,
};

base class Item {
  Item.fromJson(Json json)
    : id = json['id'] as int,
      slug = json['slug'] as String,
      type = AdItemType.fromName(json['item_type']),
      name = LocalizedString(
        canonical: json['name'] as String,
        translated: json['translated_item']?['name'] as String?,
      ),
      description = LocalizedString(
        canonical: json['description'] as String,
        translated: json['translated_item']?['description'] as String?,
      ),
      address = LocalizedString(
        canonical: json['address'] as String,
        translated: json['translated_item']?['address'] as String?,
      ),
      category = Category.fromJson(json['category'] as Json),
      price =
          (json['formatted_price'] ?? json['formatted_salary_range'])
              as String?,
      currency = Currency.fromJson(json['currency'] as Json),
      coordinates = Coordinates(
        latitude: json['latitude'] as num,
        longitude: json['longitude'] as num,
      ),
      contact = Contact(
        number: json['contact'] as String? ?? '',
        callingCode: json['country_code'] as String? ?? '',
        regionCode: json['region_code'] as String? ?? '',
      ),
      video = JsonHelper.parseObjectOrNull(
        json['item_video'] as Json?,
        ProductVideo.fromJson,
      ),
      seller = Seller.fromJson(json['user'] as Json),
      image = json['image'] as String? ?? '',
      // gallery_images repeats the main image, flagged with is_default. The
      // flag is kept rather than filtered here because the ad editing flow
      // needs every entry, ids included. Display code filters on it instead.
      images = JsonHelper.parseList(
        json['gallery_images'] as List?,
        (json) => (
          id: json['id'] as int?,
          url: json['image'] as String,
          isDefault: _parseIsDefault(json['is_default']),
        ),
      ),
      customFields = JsonHelper.parseList(
        json['all_translated_custom_fields'] as List?,
        ItemCustomField.fromJson,
      ),
      postedAt = DateTime.parse(json['published_at'] as String),
      isFeatured = json['is_feature'] as bool,
      hasAlreadyOffered = json['is_already_offered'] as bool? ?? false,
      itemOfferId = json['offer_item_id'] as int?,
      hasAlreadyJobApplied = json['is_already_job_applied'] as bool? ?? false,
      hasAlreadyReported = json['is_already_reported'] as bool? ?? false,
      isPurchased = json['is_purchased'] as bool? ?? false,
      isLiked = json['is_liked'] as bool? ?? false,
      activePromotions = json['active_promotions'] != null
          ? ActivePromotionsSummary.fromJson(json['active_promotions'] as Json?)
          : null;


  final int id;
  final String slug;
  final AdItemType type;
  final LocalizedString name;
  final LocalizedString description;
  final LocalizedString address;
  final Category category;
  final String? price;
  final Currency currency;
  final Coordinates coordinates;
  final Contact contact;
  final ProductVideo? video;
  final Seller seller;

  /// The main image, held separately from [images] (`gallery_images`) by the
  /// API. This is the one item cards show, so it is also the gallery's first
  /// page.
  final String image;
  final List<ItemImage>? images;
  final List<ItemCustomField> customFields;
  final DateTime postedAt;
  final bool isFeatured;
  final bool hasAlreadyOffered;
  final int? itemOfferId;
  final bool hasAlreadyJobApplied;
  final bool hasAlreadyReported;
  final bool isPurchased;
  final bool isLiked;
  final ActivePromotionsSummary? activePromotions;

  bool get isJobItem => category.isJobCategory;

  bool get hasPrice => price != null && price!.toLowerCase() != 'free';

  ActiveSaleItem? get primaryActiveSale =>
      (activePromotions?.sales.isNotEmpty ?? false)
          ? activePromotions!.sales.first
          : null;

  bool get hasActiveSale => primaryActiveSale != null;

  bool get isSpotlight => activePromotions?.isSpotlight ?? false;

  bool get isTopAd => activePromotions?.isTopAd ?? false;
}

class Coordinates {
  Coordinates({required num latitude, required num longitude})
    : latitude = latitude.toDouble(),
      longitude = longitude.toDouble();

  final double latitude;
  final double longitude;
}

class UserMetaData {
  UserMetaData.fromJson(Json json)
    : isLiked = json['is_liked'] as bool? ?? false,
      isAlreadyOffered = json['is_already_offered'] as bool? ?? false,
      isAlreadyJobApplied = json['is_already_job_applied'] as bool? ?? false,
      isAlreadyReported = json['is_already_reported'] as bool? ?? false;

  final bool isLiked;
  final bool isAlreadyOffered;
  final bool isAlreadyJobApplied;
  final bool isAlreadyReported;
}

class ItemCustomField {
  ItemCustomField.fromJson(Json json)
    : id = json['id'] as int,
      languageId = json['language_id'] as int,
      type = CustomFieldType.parse(json['type'] as String),
      name = json['translated_name'] as String,
      image = json['image'] as String,
      value = json['value'],
      translatedValue = json['translated_value'];

  final int id;
  final int languageId;
  final CustomFieldType type;

  // Localized from API based on content-language
  final String name;
  final String image;
  final dynamic value;
  final dynamic translatedValue;
}
