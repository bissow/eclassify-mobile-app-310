import 'dart:convert';
import 'package:eClassify/features/store/models/store_model.dart';

class LocationWarningModel {
  final bool isMatched;
  final bool warning;
  final String? message;
  final num? distanceKm;
  final String? distanceFormatted;
  final String? storeName;
  final String? storeAddress;
  final String? storeCity;
  final String? storeState;

  const LocationWarningModel({
    this.isMatched = true,
    this.warning = false,
    this.message,
    this.distanceKm,
    this.distanceFormatted,
    this.storeName,
    this.storeAddress,
    this.storeCity,
    this.storeState,
  });

  factory LocationWarningModel.fromJson(Map<String, dynamic> json) {
    final distanceMap = json['distance'] is Map ? json['distance'] as Map : null;
    final storeLoc = json['store_location'] is Map ? json['store_location'] as Map : null;

    return LocationWarningModel(
      isMatched: json['is_matched'] as bool? ?? true,
      warning: json['warning'] as bool? ?? false,
      message: json['message'] as String?,
      distanceKm: json['distance_km'] as num?,
      distanceFormatted: distanceMap?['formatted'] as String? ??
          (json['distance_km'] != null ? '${json['distance_km']} km' : null),
      storeName: storeLoc?['name'] as String?,
      storeAddress: storeLoc?['address'] as String?,
      storeCity: storeLoc?['city'] as String?,
      storeState: storeLoc?['state'] as String?,
    );
  }
}

class SellerQrCodeModel {
  final int? id;
  final int? userId;
  final int? storeId;
  final String? token;
  final String? customSlug;
  final String? catalogBaseUrl;
  final String? qrUrl;
  final String? deepLink;
  final String? format;
  final String? size;
  final String? customTagline;
  final String? customColor;
  final String? centerLogoUrl;
  final bool canCustomizeColors;
  final bool canCustomizeLogo;
  final bool canCustomizeSlug;
  final bool isActive;
  final int scansCount;
  final String? lastScannedAt;
  final String? svgRaw;
  final StoreModel? store;

  final String? title;
  final String? defaultFooterText;
  final String? footerLogoUrl;
  final String? badgeText;

  const SellerQrCodeModel({
    this.id,
    this.userId,
    this.storeId,
    this.token,
    this.customSlug,
    this.catalogBaseUrl,
    this.title,
    this.qrUrl,
    this.deepLink,
    this.format,
    this.size,
    this.customTagline,
    this.customColor,
    this.centerLogoUrl,
    this.canCustomizeColors = true,
    this.canCustomizeLogo = true,
    this.canCustomizeSlug = true,
    this.defaultFooterText,
    this.footerLogoUrl,
    this.badgeText,
    this.isActive = true,
    this.scansCount = 0,
    this.lastScannedAt,
    this.svgRaw,
    this.store,
  });

  String? get qrCodeToken => customSlug ?? token;

  factory SellerQrCodeModel.fromJson(Map<String, dynamic> rawJson) {
    final json = (rawJson['qr_code'] is Map<String, dynamic>)
        ? rawJson['qr_code'] as Map<String, dynamic>
        : (rawJson['data'] is Map<String, dynamic> && (rawJson['data'] as Map<String, dynamic>)['qr_code'] is Map<String, dynamic>)
            ? (rawJson['data'] as Map<String, dynamic>)['qr_code'] as Map<String, dynamic>
            : rawJson;

    String? rawSvg = (json['svg_raw'] ?? json['raw_svg']) as String?;
    if ((rawSvg == null || rawSvg.isEmpty) && json['qr_base64_svg'] is String) {
      final b64 = json['qr_base64_svg'] as String;
      if (b64.contains(',')) {
        try {
          rawSvg = utf8.decode(base64.decode(b64.split(',').last));
        } catch (_) {
          rawSvg = b64;
        }
      } else {
        try {
          rawSvg = utf8.decode(base64.decode(b64));
        } catch (_) {
          rawSvg = b64;
        }
      }
    }

    return SellerQrCodeModel(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      storeId: json['store_id'] as int?,
      token: (json['token'] ?? json['qr_code_token']) as String?,
      customSlug: (json['custom_slug'] ?? json['slug'] ?? json['token'] ?? json['qr_code_token']) as String?,
      catalogBaseUrl: (json['catalog_base_url'] ?? rawJson['catalog_base_url']) as String?,
      title: json['title'] as String?,
      qrUrl: json['qr_url'] as String?,
      deepLink: json['deep_link'] as String?,
      format: (json['format'] ?? json['qr_style']) as String?,
      size: json['size'] as String?,
      customTagline: (json['custom_tagline'] ?? json['tagline']) as String?,
      customColor: (json['custom_color'] ?? json['primary_color']) as String?,
      centerLogoUrl: (json['effective_center_logo_url'] ?? json['center_logo_url']) as String?,
      canCustomizeColors: (json['can_customize_colors'] ?? rawJson['can_customize_colors']) as bool? ?? true,
      canCustomizeLogo: (json['can_customize_logo'] ?? rawJson['can_customize_logo']) as bool? ?? true,
      canCustomizeSlug: (json['can_customize_slug'] ?? rawJson['can_customize_slug']) as bool? ?? true,
      defaultFooterText: (json['default_footer_text'] ?? json['footer_text'] ?? (rawJson['default_settings'] is Map ? rawJson['default_settings']['default_footer_text'] : null)) as String?,
      footerLogoUrl: (json['footer_logo_url'] ?? json['footer_logo'] ?? (rawJson['default_settings'] is Map ? rawJson['default_settings']['footer_logo_url'] : null)) as String?,
      badgeText: (json['badge_text'] ?? (rawJson['default_settings'] is Map ? rawJson['default_settings']['badge_text'] : null)) as String?,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      scansCount: json['scans_count'] as int? ?? 0,
      lastScannedAt: json['last_scanned_at'] as String?,
      svgRaw: rawSvg,
      store: json['store'] is Map
          ? StoreModel.fromJson(Map<String, dynamic>.from(json['store'] as Map))
          : null,
    );
  }
}

class SellerQrEligibilityModel {
  final bool isEligible;
  final bool hasStore;
  final bool allowsSellerQrCode;
  final String? message;
  final StoreModel? store;

  const SellerQrEligibilityModel({
    this.isEligible = false,
    this.hasStore = false,
    this.allowsSellerQrCode = false,
    this.message,
    this.store,
  });

  factory SellerQrEligibilityModel.fromJson(Map<String, dynamic> json) {
    final eligibleVal = json['is_eligible'] ?? json['eligible'] ?? false;
    return SellerQrEligibilityModel(
      isEligible: eligibleVal == 1 || eligibleVal == true,
      hasStore: json['has_store'] == 1 || json['has_store'] == true,
      allowsSellerQrCode: (json['allows_seller_qr_code'] ?? eligibleVal) == 1 ||
          (json['allows_seller_qr_code'] ?? eligibleVal) == true,
      message: json['message'] as String?,
      store: json['store'] is Map
          ? StoreModel.fromJson(Map<String, dynamic>.from(json['store'] as Map))
          : null,
    );
  }
}
