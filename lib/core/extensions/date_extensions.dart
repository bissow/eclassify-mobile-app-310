import 'package:eClassify/app/session/app_session.dart';
import 'package:intl/intl.dart';

extension DateExtensions on DateTime {
  String format({DateFormat? format, String? formatString}) {
    final locale = _resolveLocale(AppSession.currentLocale);

    final dateFormat =
        format ?? DateFormat(formatString ?? 'MMM d, yyyy', locale);
    return dateFormat.format(this);
  }

  static String? _resolveLocale(String requested) {
    if (DateFormat.localeExists(requested)) return requested;

    // find similar language locale, same as timeago fallback
    final language = requested.split('_').first;
    final similar = DateFormat.allLocalesWithSymbols().firstWhere(
      (l) => l.startsWith('${language}_'),
      orElse: () => '',
    );
    if (similar.isNotEmpty) return similar;

    if (DateFormat.localeExists(language)) return language;

    return Intl.defaultLocale;
  }
}
