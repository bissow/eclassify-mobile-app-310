import 'package:eClassify/app/app.dart';
import 'package:eClassify/app/cubit_observer.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/utils/background_upload_utility.dart';
import 'package:eClassify/core/utils/map_style.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_debug_logger/flutter_debug_logger.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart'
    as libphonenumber;
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// v3.1.0 ///

Future<void> main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();

    // Configure Google Maps for Android
    _configureGoogleMaps();

    // Set up error handling for release mode
    if (kReleaseMode) {
      _setupErrorHandling();
    }

    // Set up path to store internal files
    _setupFilePath();

    // Initialize Mobile Ads
    MobileAds.instance.initialize();

    // Initialize regions for phone number
    libphonenumber.init();

    // Load map styles from assets
    MapStyle.init();

    // Initialize background downloader notifications configuration
    BackgroundUploadUtility.initialize();

    // Configure system UI and launch app
    _configureSystemUI();

    Bloc.observer = AppCubitObserver();

    await Future.wait([
      // Init Api Client
      Api.init(),

      // Initialize Firebase
      _initializeFirebase(),

      // Initialize Hive and open boxes
      _initializeHive(),
    ]);

    // Create app session from stored values
    // Note: Must be called "after" hive is initialized
    AppSession.create();

    await DebugLogger.init();

    runApp(FlutterDebugLogger.wrap(child: const AppScope()));
  } catch (e, st) {
    debugPrint('Error initializing app: $e $st');
    rethrow;
  }
}

/// Configures Google Maps for Android platform
void _configureGoogleMaps() {
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = false;
    mapsImplementation.warmup();
  }
}

/// Sets up error handling for release mode
void _setupErrorHandling() {
  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    return QErrorWidget(error: flutterErrorDetails.exception);
  };
}

/// Initializes Firebase with appropriate options
Future<void> _initializeFirebase() async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    if (e is! FirebaseException || e.code != 'duplicate-app') {
      rethrow;
    }
  }

  await FirebaseAppCheck.instance.activate(
    providerApple: kDebugMode ? AppleDebugProvider() : AppleAppAttestProvider(),
    providerAndroid: kDebugMode
        ? AndroidDebugProvider()
        : AndroidPlayIntegrityProvider(),
  );
}

/// Initializes Hive and opens all required boxes
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Boxes read before the first frame, so they must be open up front.
  // HiveKeys.historyBox is deliberately absent: search history is only
  // touched on demand, and SearchHistoryStorage opens it lazily.
  final List<String> hiveBoxes = [
    HiveKeys.userDetailsBox,
    HiveKeys.authBox,
    HiveKeys.languageBox,
    HiveKeys.themeBox,
  ];

  final boxesFuture = [for (final box in hiveBoxes) Hive.openBox(box)];

  await Future.wait(boxesFuture);
}

/// Configures system UI and launches the app
Future<void> _configureSystemUI() async {
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final brightness = AppSession.isDarkMode ? Brightness.light : Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarIconBrightness: brightness,
      systemNavigationBarContrastEnforced: false,
      systemStatusBarContrastEnforced: false,
    ),
  );
}

/// Setup the file path for saving internal files
Future<void> _setupFilePath() async {
  final directory = await getApplicationDocumentsDirectory();
  Constant.savePath = directory.path;
}
