import 'package:collection/collection.dart';
import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/features/custom_fields/enums/custom_field_type.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/models/ad_posting_data.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';

extension ItemPreviewExtension on ItemPreview {
  bool get isMyAd {
    final adUserId = this.userId;
    final myId = AppSession.currentUser?.id;

    return adUserId.toString() == myId.toString();
  }
}

extension ItemExtension on Item {
  ItemPreview toPreview() {
    return ItemPreview(
      id: this.id,
      userId: this.seller.id,
      image: this.image,
      price: this.price,
      name: this.name.localized,
      address: this.address.localized,
      postedAt: this.postedAt,
    );
  }

  bool get isMyAd {
    final adUserId = this.seller.id;
    final myId = AppSession.currentUser?.id;

    return adUserId.toString() == myId.toString();
  }

  /// Returns a map of fieldId to a map of languageId to ItemCustomField
  Map<int, Map<int, ItemCustomField>> get customFieldsByFieldId {
    final groupByFieldId = groupBy(customFields, (element) => element.id);
    final customFieldsByFieldId = <int, Map<int, ItemCustomField>>{};
    for (final entries in groupByFieldId.entries) {
      final fieldId = entries.key;
      final fields = entries.value;
      for (final field in fields) {
        customFieldsByFieldId.putIfAbsent(
          fieldId,
          () => <int, ItemCustomField>{},
        );
        customFieldsByFieldId[fieldId]![field.languageId] = field;
      }
    }

    return customFieldsByFieldId;
  }
}

extension MyItemExtension on MyItem {
  AdPostingData? toAdPostingData() {
    final itemType = this.type;
    final category = this.category;

    // Basic Details
    final price = _extractPrice();
    final contact = _extractContactDetails();

    final basicDetails = BasicDetails(
      title: this.name.canonical,
      description: this.description.canonical,
      slug: this.slug,
      price: price,
      contact: contact,
    );

    // Localized Content
    final localizedContent = _extractLocalizedContent();

    // SEO Data
    final seoData = _extractSeoData();

    // Custom Fields
    final customFields = _extractCustomFields();

    final images = this.images
        ?.map((e) => RemoteFileResource(Uri.parse(e.url), id: e.id))
        .toList();

    // Location
    final location = LeafLocation(
      latitude: this.coordinates.latitude,
      longitude: this.coordinates.longitude,
    );

    final data = AdPostingData(
      id: this.id,
      adType: itemType,
      category: category,
      basicDetails: basicDetails,
      localizedContent: localizedContent,
      seoData: seoData,
      customFields: customFields,
      images: images,
      location: location,
      productVideo: this.video,
      isResubmission: this.status == ItemStatus.softRejected,
    );

    return data;
  }

  DraftListingValue? _extractPrice() {
    if (this.category.isJobCategory) {
      final salary = this.listingValue as Salary;
      return DraftSalary(
        minSalary: salary.minSalary != null ? salary.minSalary.toString() : '',
        maxSalary: salary.maxSalary != null ? salary.maxSalary.toString() : '',
        currency: this.currency,
      );
    } else {
      final value = this.listingValue as Price;
      return DraftPrice(
        price: value.price != null ? value.price.toString() : '',
        currency: this.currency,
      );
    }
  }

  Contact? _extractContactDetails() {
    if (this.contact.isEmpty) {
      return null;
    }
    return this.contact.copyWith(
      callingCode: this.contact.callingCode.isEmpty
          ? AppConfig.defaultPhoneCode
          : this.contact.callingCode,
      regionCode: this.contact.regionCode.isEmpty
          ? AppConfig.defaultCountryCode
          : this.contact.regionCode,
    );
  }

  Map<int, LocalizedContent>? _extractLocalizedContent() {
    if (this.translations.isNullOrEmpty) return null;
    final localizedContent = <int, LocalizedContent>{};
    final translationsByLanguage = groupBy(this.translations, (element) {
      final languageId = int.tryParse(element['language_id'].toString()) ?? -1;
      return languageId;
    });

    for (final field in translationsByLanguage.entries) {
      final languageId = field.key;
      final translations = field.value;
      final translationsByKey = groupBy(
        translations,
        (element) => element['key'],
      );
      final content = LocalizedContent(
        title: translationsByKey['name']?.firstOrNull?['value'] as String?,
        description:
            translationsByKey['description']?.firstOrNull?['value'] as String?,
      );
      localizedContent[languageId] = content;
    }

    return localizedContent;
  }

  Map<int, CustomFieldData> _extractCustomFields() {
    final groupByFieldId = groupBy(
      customFields,
      (element) => element.languageId,
    );
    final customFieldsByFieldId = <int, Map<int, dynamic>>{};
    for (final entries in groupByFieldId.entries) {
      final fieldId = entries.key;
      final fields = entries.value;
      for (final field in fields) {
        final value = switch (field.type) {
          CustomFieldType.textbox ||
          CustomFieldType.number ||
          CustomFieldType.radio ||
          CustomFieldType.dropdown => (field.value as List?)?.firstOrNull,
          CustomFieldType.checkbox => (field.value as List?)?.cast<String>(),
          CustomFieldType.file when field.value is String =>
            FileResource.fromPath(field.value),
          _ => throw ('Unsupported field type: ${field.type}'),
        };
        customFieldsByFieldId.putIfAbsent(fieldId, () => <int, dynamic>{});
        customFieldsByFieldId[field.languageId]![field.id] = value;
      }
    }

    return customFieldsByFieldId;
  }

  Map<int, SeoData>? _extractSeoData() {
    if (this.seoDetails == null) return null;
    final seoData = <int, SeoData>{};
    final defaultLanguageId = Constant.systemSettings.defaultLanguage.id;

    final defaultLanguageSeo = SeoData(
      metaTitle: this.seoDetails!.metaTitle,
      metaDescription: this.seoDetails!.metaDescription,
      metaKeywords: this.seoDetails!.metaKeywords,
      schema: this.seoDetails!.schema,
    );

    seoData[defaultLanguageId] = defaultLanguageSeo;
    if (this.translations.isNullOrEmpty) return seoData;

    for (final fields in this.translations) {
      final languageId = int.tryParse(fields['language_id'].toString()) ?? -1;
      final metaTitle = fields['meta_title'] as String?;
      final metaDescription = fields['meta_description'] as String?;
      final metaKeywords = fields['meta_keywords'] as String?;
      final schema = fields['schema'] as String?;
      final seo = SeoData(
        metaTitle: metaTitle,
        metaDescription: metaDescription,
        metaKeywords: metaKeywords,
        schema: schema,
      );
      seoData[languageId] = seo;
    }
    return seoData;
  }
}
