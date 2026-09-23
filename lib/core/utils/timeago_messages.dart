import 'package:eClassify/app/session/app_session.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:timeago_flutter/timeago_flutter.dart';

class TimeagoMessages {
  /// Registers timeago message lookups for the current session locale,
  /// both long ("2 hours ago") and short ("2h") variants.
  static void applyLocale() {
    timeago.setLocaleMessages(
      AppSession.currentLocale,
      getMessages(AppSession.currentLocale),
    );
    timeago.setLocaleMessages(
      AppSession.currentLocaleShort,
      getMessages(AppSession.currentLocaleShort),
    );
  }

  static final _messageMap = {
    'en_US': timeago.EnMessages(),
    'en_US_short': timeago.EnShortMessages(),
    'ar_SA': timeago.ArMessages(),
    'ar_SA_short': timeago.ArShortMessages(),
    'fr_FR': timeago.FrMessages(),
    'fr_FR_short': timeago.FrShortMessages(),
    'hi_IN': timeago.HiMessages(),
    'hi_IN_short': timeago.HiShortMessages(),
    'pt_BR': timeago.PtBrMessages(),
    'pt_BR_short': timeago.PtBrShortMessages(),
    'es_ES': timeago.EsMessages(),
    'es_ES_short': timeago.EsShortMessages(),
    'tr_TR': timeago.TrMessages(),
    'tr_TR_short': timeago.TrShortMessages(),
  };

  static LookupMessages getMessages(String locale) {
    final lookup = _messageMap[locale];
    if (lookup != null) {
      return lookup;
    }

    // Requested locale may carry a `_short` suffix (e.g. `es_MX_short`).
    // Strip it so the fallback search matches the same variant it was
    // asked for, instead of possibly returning the long-form messages.
    final isShort = locale.endsWith('_short');
    final base = locale.replaceAll('_short', '');
    final language = base.split('_').first;

    // find similar language lookup, preserving the short/long variant
    for (final entry in _messageMap.entries) {
      final matchesLanguage = entry.key.startsWith('${language}_') &&
          entry.key.endsWith('_short') == isShort;
      if (matchesLanguage) {
        return entry.value;
      }
    }

    return isShort ? _messageMap['en_US_short']! : _messageMap['en_US']!;
  }
}
