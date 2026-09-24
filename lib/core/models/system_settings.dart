import 'dart:io';

import 'package:eClassify/core/enums/map_provider_type.dart';
import 'package:eClassify/core/enums/otp_provider_type.dart';
import 'package:eClassify/core/models/company_details.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/models/version.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class SystemSettings {
  SystemSettings.fromJson(Json json)
    : demoMode = json['demo_mode'] as bool,
      version = _platformResolver(
        json['android_version'] as String,
        json['ios_version'] as String,
        Version.fromString,
      ),
      defaultLanguageCode = json['default_language'] as String,
      currentLanguageCode = json['current_language'] as String,
      forceUpdate = (json['force_update'] as String?) == '1',
      maintenanceMode = _platformResolver(
        json['android_maintenance_mode'],
        json['ios_maintenance_mode'],
        (v) => v == '1',
      ),
      isFreeAdListingEnabled = (json['free_ad_listing'] as String?) == '1',
      otpProvider = OtpProviderType.fromRaw(
        (json['otp_service_provider'] as String?) ?? '',
      ),
      mapProvider = MapProviderType.fromRaw(json['map_provider'] as String),
      defaultCurrency = Currency.fromJson({
        'symbol': json['currency_symbol'],
        'iso_code': json['currency_iso_code'],
        'symbol_position': json['currency_symbol_position'],
      }),

      _isBannerAdEnabled = (json['banner_ad_status'] as String?) == '1',
      bannerAdId = _platformResolver(
        json['banner_ad_id_android'] as String?,
        json['banner_ad_id_ios'] as String?,
        (v) => v,
      ),
      _isInterstitialAdEnabled =
          (json['interstitial_ad_status'] as String?) == '1',
      interstitialAdId = _platformResolver(
        json['interstitial_ad_id_android'] as String?,
        json['interstitial_ad_id_ios'] as String?,
        (v) => v,
      ),
      _isNativeAdEnabled = (json['native_ad_status'] as String?) == '1',
      nativeAdId = _platformResolver(
        json['native_app_id_android'] as String?,
        json['native_app_id_ios'] as String?,
        (v) => v,
      ),
      storeLink = _platformResolver(
        json['play_store_link'] as String?,
        json['app_store_link'] as String?,
        (v) => v,
      ),
      defaultLatitude = num.tryParse(json['default_latitude'].toString()),
      defaultLongitude = num.tryParse(json['default_longitude'].toString()),
      minRadius = num.parse(json['min_length'] as String),
      maxRadius = num.parse(json['max_length'] as String),
      isEmailAuthEnabled = (json['email_authentication'] as String?) == '1',
      isPhoneAuthEnabled = (json['mobile_authentication'] as String?) == '1',
      isGoogleAuthEnabled = (json['google_authentication'] as String?) == '1',
      isAppleAuthEnabled = (json['apple_authentication'] as String?) == '1',
      isReferAndEarnEnabled = (json['refer_earn_enabled'] as String?) == '1',
      geminiAiEnabled = (json['gemini_ai_enabled'] as String?) == '1',
      maxGalleryImages =
          int.tryParse(json['max_gallery_images'].toString()) ?? 5,
      maxVideoSize =
          int.tryParse(json['item_video_max_file_size_mb'].toString()) ?? 50,
      maxReelDuration =
          int.tryParse(json['reel_max_duration_sec'].toString()) ?? 60,
      maxReelSize =
          int.tryParse(json['reel_max_file_size_mb'].toString()) ?? 50,
      languages = JsonHelper.parseList(
        json['languages'] as List?,
        Language.fromJson,
      ),
      companyDetails = CompanyDetails.fromJson(json);

  static T _platformResolver<T, V>(V android, V ios, T converter(V value)) {
    if (Platform.isAndroid) {
      return converter(android);
    } else if (Platform.isIOS) {
      return converter(ios);
    }
    throw UnimplementedError('How did you even reach here???');
  }

  final bool demoMode;
  final Version version;
  final String defaultLanguageCode;

  // To Handle an edge case where the language stored locally on device has been
  // deleted in the server
  final String currentLanguageCode;
  final bool forceUpdate;
  final bool maintenanceMode;
  final bool isFreeAdListingEnabled;

  final OtpProviderType otpProvider;

  final MapProviderType mapProvider;

  final Currency defaultCurrency;

  final bool _isBannerAdEnabled;
  final String? bannerAdId;
  final bool _isInterstitialAdEnabled;
  final String? interstitialAdId;
  final bool _isNativeAdEnabled;
  final String? nativeAdId;

  final String? storeLink;

  final num? defaultLatitude;
  final num? defaultLongitude;
  final num minRadius;
  final num maxRadius;

  final bool isEmailAuthEnabled;
  final bool isPhoneAuthEnabled;
  final bool isGoogleAuthEnabled;
  final bool isAppleAuthEnabled;

  final bool isReferAndEarnEnabled;
  final bool geminiAiEnabled;

  final int maxGalleryImages;
  final int maxVideoSize;
  final int maxReelDuration;
  final int maxReelSize;

  final CompanyDetails companyDetails;

  final List<Language> languages;

  Language get defaultLanguage => languages.firstWhere((l) => l.isDefault);

  bool get isBannerAdEnabled => _isBannerAdEnabled && bannerAdId != null;

  bool get isInterstitialAdEnabled =>
      _isInterstitialAdEnabled && interstitialAdId != null;

  bool get isNativeAdEnabled => _isNativeAdEnabled && nativeAdId != null;
}
