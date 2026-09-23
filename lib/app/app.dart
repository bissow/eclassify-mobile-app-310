import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/app/provider_registry.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/cubits/app_theme_cubit.dart';
import 'package:eClassify/core/cubits/language_cubit.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppScope extends StatelessWidget {
  const AppScope({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: ProviderRegistry.instance.providers,
      child: const App(),
    );
  }
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void reassemble() {
    super.reassemble();
    // Reload the local translation asset on hot reload for quick testing
    if (kDebugMode && AppSession.currentLanguage?.languageCode == 'en') {
      context.read<LanguageCubit>().reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = context.watch<AppThemeCubit>().state;
    final currentLanguage = context.select<LanguageCubit, Language?>(
      (c) => switch (c.state) {
        LanguageFetchSuccess(language: final language) => language,
        _ => null,
      },
    );
    final isDark = currentTheme == ThemeMode.dark;

    final overlayStyle = SystemUiOverlayStyle(
      // iOS Only
      statusBarBrightness: isDark
          ? Brightness.dark
          : Brightness.light, // iOS background brightness
      // Android Only
      statusBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark, // Android icons
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: MaterialApp(
        key: ValueKey(AppConfig.applicationName),
        scrollBehavior: ScrollConfiguration.of(
          context,
        ).copyWith(overscroll: false),
        initialRoute: Routes.splash,
        navigatorKey: Constant.navigatorKey,
        navigatorObservers: [
          Constant.routeObserver,
          Constant.appNavigatorObserver,
        ],
        title: AppConfig.applicationName,
        debugShowCheckedModeBanner: false,
        onGenerateRoute: Routes.onGenerateRouted,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: currentTheme,
        builder: (context, child) {
          final direction = currentLanguage?.isRTL ?? false
              ? TextDirection.rtl
              : TextDirection.ltr;

          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.0)),
            child: Directionality(textDirection: direction, child: child!),
          );
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: currentLanguage?.locale ?? const Locale('en'),
        localeResolutionCallback: (locale, supported) {
          if (locale != null &&
              GlobalMaterialLocalizations.delegate.isSupported(locale)) {
            return locale;
          }
          return const Locale('en');
        },
      ),
    );
  }
}
