import 'dart:async';

import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/app/widgets/session_end_listener.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/cubits/language_cubit.dart';
import 'package:eClassify/core/cubits/system_settings_cubit.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/models/system_settings.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/core/utils/version_utility.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/home/cubits/home_screen_configuration_cubit.dart';
import 'package:eClassify/features/onboarding/storage/onboarding_storage.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const SplashScreen(),
    );
  }
}

class _SplashScreenState extends State<SplashScreen> {
  // Completers used to coordinate the asynchronous startup flow.
  // Using Completers allows us to sequentially fetch configuration settings,
  // load localized language assets, and transition screens.
  late Completer<SystemSettings> _settingsCompleter;
  late Completer<void> _languageCompleter;

  // Holds the error context when setting or language retrieval fails,
  // prompting a screen update to render the retry error widget.
  Object? _error;

  @override
  void initState() {
    super.initState();
    _startNavigationFlow();
  }

  /// Runs the step-by-step sequence of asynchronous actions required to boot the application.
  ///
  /// 1. Concurrently starts fetching system settings and home screen configurations.
  /// 2. Suspends until system settings are retrieved successfully.
  /// 3. Dispatches language localization fetching based on user-configured or default parameters.
  /// 4. Suspends until the localization file has finished loading.
  /// 5. Validates system modes (like Maintenance mode) and user authentication status,
  ///    routing the user to the correct initial page.
  void _startNavigationFlow() async {
    try {
      // Re-instantiate the completers on each loading attempt to avoid caching past results.
      _settingsCompleter = Completer<SystemSettings>();
      _languageCompleter = Completer<void>();

      context.read<SystemSettingsCubit>().getSystemSettings();
      context.read<HomeConfigurationCubit>().getHomeConfiguration();

      // Step 1: Wait for system settings
      final settings = await _settingsCompleter.future;
      if (!mounted) return;

      // Step 2: Load default or active locale settings
      _loadLanguage(
        currentLanguageCode: settings.currentLanguageCode,
        defaultLanguage: settings.defaultLanguage,
      );

      // Step 3: Wait for language translations to be downloaded
      await _languageCompleter.future;
      if (!mounted) return;

      // Step 4: Block on a mandatory update before anything else mounts —
      // resolving this here (rather than as a dialog over MainScreen) means
      // the home screen and its API calls never run against a build they're
      // incompatible with.
      if (settings.forceUpdate &&
          await VersionUtility.isUpdateAvailable(settings.version)) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed(Routes.appUpdate);
        return;
      }

      // Step 5: Route the user based on settings and authentication states
      if (settings.maintenanceMode) {
        Navigator.of(context).pushReplacementNamed(Routes.maintenanceMode);
      } else if (!OnboardingStorage.hasCompletedOnboarding()) {
        Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.main);
      }
    } catch (e, st) {
      // Catch failure states bubbled up through the completers
      if (!mounted) return;
      Log.error(e.toString(), e, st);

      // A dead session isn't a boot failure the user can do anything about.
      // `AuthSessionCubit` is already clearing the token, and its callback
      // restarts this flow — hold the splash UI until then rather than
      // flashing an error widget the user would only retry into.
      if (ApiErrorHelper.isUnauthenticated(e)) return;

      _error = e;
      setState(() {});
    }
  }

  /// Restarts the boot flow after the session ended mid-boot. The stale token
  /// has been cleared by then, so the same requests are simply retried as a
  /// guest and the user stays on this screen while they run — no redirect, no
  /// half-booted auth screen. A second 401 can't loop back here:
  /// `AuthSessionCubit.forceLogout` is a no-op once already unauthenticated.
  void _restartAfterSessionEnd() {
    // Deferred by a frame so the failure states of the abandoned requests land
    // on the current completers, where the 401 branch above swallows them and
    // that attempt quietly ends, rather than on the ones this restart creates.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _error = null;
      setState(() {});
      _startNavigationFlow();
    });
  }

  /// Loads the language translations from either the app session storage
  /// (if active and matching) or fallbacks to the settings' default language.
  void _loadLanguage({
    required String currentLanguageCode,
    required Language defaultLanguage,
  }) {
    final persistedLanguage = AppSession.currentLanguage;
    // Check if the persisted language is still valid and matches the current language.
    if (persistedLanguage != null &&
        persistedLanguage.languageCode == currentLanguageCode) {
      context.read<LanguageCubit>().loadLanguage(persistedLanguage);
    } else {
      context.read<LanguageCubit>().loadLanguage(defaultLanguage);
    }
  }

  Widget? _companyLogo() {
    if (AppConfig.showCompanyLogo) {
      return SizedBox(
        height: kToolbarHeight,
        child: Center(
          child: CustomImage(
            src: AppAssets.branding.company,
            fit: BoxFit.contain,
          ),
        ),
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Material(
        color: context.colorScheme.surface,
        child: Center(
          child: QErrorWidget(
            error: _error,
            onRetry: () {
              _error = null;
              setState(() {});
              _startNavigationFlow();
            },
          ),
        ),
      );
    }

    return SessionEndListener(
      onSessionEnded: _restartAfterSessionEnd,
      child: MultiBlocListener(
        listeners: [
          // Listens for system setting fetch outcomes and completes/errors the settings completer.
          BlocListener<SystemSettingsCubit, SystemSettingsState>(
            listener: (context, state) {
              if (state is SystemSettingsSuccess) {
                if (!_settingsCompleter.isCompleted) {
                  _settingsCompleter.complete(state.settings);
                }
              }
              if (state is SystemSettingsFailure) {
                if (!_settingsCompleter.isCompleted) {
                  _settingsCompleter.completeError(state.error);
                }
              }
            },
          ),
          // Listens for language loading outcomes and completes/errors the language completer.
          BlocListener<LanguageCubit, LanguageState>(
            listener: (context, state) {
              if (state is LanguageSuccess) {
                if (!_languageCompleter.isCompleted) {
                  _languageCompleter.complete();
                }
              }
              if (state is LanguageFailure) {
                if (!_languageCompleter.isCompleted) {
                  _languageCompleter.completeError(state.error);
                }
              }
            },
          ),
        ],
        child: AppScaffold(
          backgroundColor: context.colorScheme.primary,
          bottomAction: _companyLogo(),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              CustomImage(
                src: AppAssets.branding.logo,
                size: Size.square(150),
                fit: BoxFit.scaleDown,
              ),
              Text(
                AppConfig.applicationName,
                style: context.headlineLarge.copyWith(
                  color: context.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
