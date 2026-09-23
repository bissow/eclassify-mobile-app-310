import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';

class LanguageStorage {
  LanguageStorage._();

  static Language? getLanguage() {
    try {
      final stored = HiveStorage.read<dynamic>(
        HiveKeys.languageBox,
        HiveKeys.currentLanguageKey,
      );
      if (stored == null) return null;
      return Language.fromJson(Map<String, dynamic>.from(stored));
    } catch (e) {
      return null;
    }
  }

  static Future<void> storeLanguage(Language language) => HiveStorage.write(
    HiveKeys.languageBox,
    HiveKeys.currentLanguageKey,
    language.toJson(),
  );

  static Future<void> clearLanguage() =>
      HiveStorage.clearBox(HiveKeys.languageBox);
}
