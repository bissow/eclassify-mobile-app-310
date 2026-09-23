import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/item/models/product_video.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';

typedef CustomFieldData = Map<int, dynamic>;

class AdPostingData {
  // Available during editing
  final int? id;
  final AdItemType? adType;
  final Category? category;
  final BasicDetails? basicDetails;
  final Map<int, LocalizedContent>? localizedContent;
  final Map<int, SeoData>? seoData;
  final Map<int, CustomFieldData>? customFields;
  final List<FileResource>? images;
  final List<int>? deletedImages;
  final ProductVideo? productVideo;

  // Set to true if the video is of type RemoteFileResource and should be deleted,
  final bool? deleteProductVideo;
  final FileResource? videoAd; // Reel
  final FileResource? thumbnail; // Reel
  final LeafLocation? location;

  // Uses solely for dynamic label in the last ad posting step
  final bool isResubmission;

  const AdPostingData({
    this.id,
    this.adType,
    this.category,
    this.basicDetails,
    this.localizedContent,
    this.seoData,
    this.customFields,
    this.images,
    this.deletedImages,
    this.productVideo,
    this.deleteProductVideo,
    this.videoAd,
    this.thumbnail,
    this.location,
    this.isResubmission = false,
  });

  AdPostingData copyWith({
    AdItemType? itemType,
    Category? category,
    BasicDetails? basicDetails,
    MapEntry<int, LocalizedContent>? localizedContentEntry,
    Map<int, SeoData>? seoData,
    MapEntry<int, CustomFieldData>? customFieldsEntry,
    List<FileResource>? images,
    List<int>? deletedImages,
    ProductVideo? video,
    bool? deleteProductVideo,
    FileResource? videoAd,
    FileResource? thumbnail,
    LeafLocation? location,
  }) {
    var localizedContent = this.localizedContent ?? {};
    if (localizedContentEntry != null) {
      localizedContent[localizedContentEntry.key] = localizedContentEntry.value;
    }

    var customFields = this.customFields ?? {};
    if (customFieldsEntry != null) {
      customFields[customFieldsEntry.key] = customFieldsEntry.value;
    }

    return AdPostingData(
      id: this.id,
      adType: itemType ?? this.adType,
      category: category ?? this.category,
      basicDetails: basicDetails ?? this.basicDetails,
      seoData: seoData ?? this.seoData,
      localizedContent: localizedContent,
      customFields: customFields,
      images: images ?? this.images,
      deletedImages: deletedImages ?? this.deletedImages,
      productVideo: video ?? this.productVideo,
      deleteProductVideo: deleteProductVideo ?? this.deleteProductVideo,
      videoAd: videoAd ?? this.videoAd,
      thumbnail: thumbnail ?? this.thumbnail,
      location: location ?? this.location,
    );
  }

  Json get toJson => {
    'id': ?id,
    'item_type': ?adType?.value,
    'category_id': ?category?.id,
    ...?basicDetails?.toJson,
    if (seoData.isNotNullAndNotEmpty)
      'seo_details': {
        ...?seoData?.map((l, data) => MapEntry(l.toString(), data.toJson)),
      },
    if (localizedContent.isNotNullAndNotEmpty)
      'translations': {
        ...localizedContent!.map(
          (l, data) => MapEntry(l.toString(), data.toJson),
        ),
      },
    if (customFields.isNotNullAndNotEmpty)
      'custom_field_translations': {
        ...customFields!.map((l, data) => MapEntry(l, data)),
      },
    if (deletedImages.isNotNullAndNotEmpty)
      'delete_item_image_id': deletedImages,
    if (deleteProductVideo ?? false) 'delete_product_video': 1,
    'address': ?location?.canonicalPath,
    'latitude': ?location?.latitude,
    'longitude': ?location?.longitude,
    'country': ?location?.country?.canonical,
    'city': ?location?.city?.canonical,
    'state': ?location?.state?.canonical,
    'area': ?location?.area?.canonical,
  };

  @override
  String toString() {
    return 'AdPostingData{id: $id, adType: $adType, category: $category, basicDetails: $basicDetails, localizedContent: $localizedContent, seoData: $seoData, customFields: $customFields, images: $images, deletedImages: $deletedImages, productVideo: $productVideo, videoAd: $videoAd, thumbnail: $thumbnail, location: $location}';
  }
}

class BasicDetails {
  BasicDetails({
    required this.title,
    required this.description,
    this.slug,
    this.price,
    this.contact,
  });

  final String title;
  final String? slug;
  final String description;
  final DraftListingValue? price;
  final Contact? contact;

  Json get toJson => {
    'name': title,
    'description': description,
    'slug': ?(slug.isNullOrEmpty) ? null : slug,
    ...?(price?.toJson.isEmpty ?? true) ? null : price?.toJson,
    // callingCode/regionCode are always set to defaults by PhoneInputController,
    // so an empty number is what indicates the user left contact blank.
    ...?(contact == null || contact!.isEmpty)
        ? null
        : {
            'contact': contact!.number,
            'country_code': contact!.callingCode,
            'region_code': contact!.regionCode,
          },
  };
}

class LocalizedContent {
  LocalizedContent({this.title, this.description});

  final String? title;
  final String? description;

  Json get toJson => {
    'name': ?(title.isNullOrEmpty) ? null : title,
    'description': ?(description.isNullOrEmpty) ? null : description,
  };
}

class SeoData {
  SeoData({
    this.metaTitle,
    this.metaDescription,
    this.metaKeywords,
    this.schema,
  });

  String? metaTitle;
  String? metaDescription;
  String? metaKeywords;
  String? schema;

  bool get isEmpty =>
      metaTitle == null ||
      metaDescription == null ||
      metaKeywords == null ||
      schema == null;

  Json get toJson => {
    'meta_title': ?(metaTitle.isNullOrEmpty) ? null : metaTitle,
    'meta_description': ?(metaDescription.isNullOrEmpty)
        ? null
        : metaDescription,
    'meta_keywords': ?(metaKeywords.isNullOrEmpty) ? null : metaKeywords,
    'schema': ?(schema.isNullOrEmpty) ? null : schema,
  };
}

abstract class DraftListingValue {
  const DraftListingValue({required this.currency});

  final Currency currency;

  Json get toJson => {'currency_id': ?currency.id};

  /// Strips the currency's thousand separator and normalizes its decimal
  /// separator to "." so formatted display values (e.g. "1,234.56") are
  /// safe to send to the API.
  String? normalize(String value) {
    if (value.isNullOrEmpty) return null;

    final thousandSeparator = currency.thousandSeparator ?? ',';
    final decimalSeparator = currency.decimalSeparator ?? '.';

    var normalized = value.replaceAll(thousandSeparator, '');
    if (decimalSeparator != '.') {
      normalized = normalized.replaceAll(decimalSeparator, '.');
    }
    return normalized;
  }
}

class DraftPrice extends DraftListingValue {
  DraftPrice({required this.price, required super.currency});

  final String price;

  @override
  Json get toJson => {
    'price': ?normalize(price),
    if (price.isNotNullAndNotEmpty) ...super.toJson,
  };
}

class DraftSalary extends DraftListingValue {
  DraftSalary({
    required this.minSalary,
    required this.maxSalary,
    required super.currency,
  });

  final String minSalary;
  final String maxSalary;

  @override
  Json get toJson => {
    'min_salary': ?normalize(minSalary),
    'max_salary': ?normalize(maxSalary),
    if (minSalary.isNotNullAndNotEmpty || maxSalary.isNotNullAndNotEmpty)
      ...super.toJson,
  };
}
