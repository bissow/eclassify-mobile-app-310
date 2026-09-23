import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/storage/language_storage.dart';
import 'package:eClassify/core/storage/theme_storage.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/features/auth/services/local_session_service.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/location/storage/location_storage.dart';
import 'package:flutter/material.dart';

/// Holds mutable, session-scoped data used throughout the app.
///
/// This class represents the current app session and should only contain
/// data that is expected to change during a single run of the app.
///
/// For non-session data, see constants.dart.
///
/// Initialized with default values and expected to change during the app's lifecycle.
abstract class AppSession {
  /// To initialize session based values during the app booting time and ensure
  /// we have valid data to be used before accessing any of the data
  static void create() {
    _currentLocation = LocationStorage.getLocation();
    _currentTheme = ThemeStorage.getCurrentTheme();
    _currentLanguage = LanguageStorage.getLanguage();

    final localSessionService = LocalSessionService();
    _currentUser = localSessionService.getLocalUser();
    _jwtToken = localSessionService.getLocalJwtToken();
  }

  static void clear() {
    _currentLocation = AppConfig.defaultLocation;
    _activeChatId = null;
    _currentUser = null;
    _jwtToken = null;
  }

  /// Current logged-in user
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static void setCurrentUser(User? user) {
    _currentUser = user;
  }

  /// Current session JWT token
  static String? _jwtToken;

  static String? get jwtToken => _jwtToken;

  static void setJwtToken(String? token) {
    _jwtToken = token;
  }

  static bool get isAuthenticated => _currentUser != null && _jwtToken != null;

  /// Current open chat session ID
  static int? _activeChatId;

  static void setActiveChatId(int? id) {
    _activeChatId = id;
  }

  static int? get activeChatId => _activeChatId;

  /// Name of whatever route is currently on top of the navigator stack.
  /// Kept in sync by [RouteNameTrackerObserver]. Unlike reading
  /// `ModalRoute.of(context)` from a widget that lives at a fixed position
  /// in the tree (which only ever reflects *that* widget's own ancestor
  /// route, not whatever is actually current), this reflects the real
  /// top-of-stack at any point in time.
  static String? _currentRouteName;

  static String? get currentRouteName => _currentRouteName;

  static void setCurrentRouteName(String? name) {
    _currentRouteName = name;
  }

  /// Current selected location
  static LeafLocation? _currentLocation;

  static LeafLocation? get currentLocation => _currentLocation;

  static void setCurrentLocation(LeafLocation? location) {
    _currentLocation = location;
  }

  /// Current active language.
  static Language? _currentLanguage;

  static Language? get currentLanguage => _currentLanguage;

  static String get currentLanguageCode =>
      _currentLanguage?.languageCode ?? 'en';

  static String get currentLocale =>
      _currentLanguage != null ? _currentLanguage!.localeString : 'en_US';

  /// For short timeago messages
  static String get currentLocaleShort => '${currentLocale}_short';

  static void setCurrentLanguage(Language? language) {
    _currentLanguage = language;
  }

  /// Current theme of app
  static ThemeMode _currentTheme = ThemeMode.light;

  static bool get isDarkMode => _currentTheme == ThemeMode.dark;

  static void setCurrentTheme(ThemeMode theme) {
    _currentTheme = theme;
  }
}
