import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';

class AppConfig {
  /// Used in SplashScreen to display application name under splash logo
  static const String applicationName = 'eClassify';

  /// DO NOT ADD "/" AT THE END OF DOMAINS ///
  /// Admin Panel URL
  static const String hostUrl = "https://eclassify.wrteam.me";

  /// Website URL to generate share links
  static const String shareDomain = "https://eclassifyweb.wrteam.me";

  /// Default location to be used when App is unable to fetch current location
  static final LeafLocation defaultLocation = LeafLocation.global();

  /// Example of default location other than global
  // static LeafLocation defaultLocation = LeafLocation(
  //   country: LocalizedString(canonical: 'India'),
  //   state: LocalizedString(canonical: 'Gujarat'),
  //   city: LocalizedString(canonical: 'Bhuj'),
  // );

  /// Fallback latitude/longitude used only when the Admin Panel hasn't
  /// configured a default (i.e. [Constant.systemSettings] value is missing
  /// or unparseable).
  static const double _fallbackLatitude = 25.0760224;
  static const double _fallbackLongitude = 55.2274879;

  /// Default latitude and longitude to show on the Google Map when the
  /// user hasn't selected a location.
  ///
  /// Prefers the Admin Panel's configured default, falling back to
  /// [_fallbackLatitude]/[_fallbackLongitude] when that isn't set.
  static double get defaultLatitude =>
      Constant.systemSettings.defaultLatitude?.toDouble() ?? _fallbackLatitude;

  static double get defaultLongitude =>
      Constant.systemSettings.defaultLongitude?.toDouble() ??
      _fallbackLongitude;

  /// 2-Digit ISO code of Country
  /// Refer to countrycode.org to find out country's 2-Digit ISO code
  static const String defaultCountryCode = 'IN';

  /// Calling code of country
  /// DO NOT USE + SIGN IN FRONT OF CODE
  static const String defaultPhoneCode = '91';

  /// Show the company logo at the bottom of splash screen
  /// To change the logo, replace assets/icons/branding/company_logo.svg
  /// SVG format is recommended here.
  /// To use any other formats, provide full asset URL in splash_screen.dart
  static const bool showCompanyLogo = true;
}
