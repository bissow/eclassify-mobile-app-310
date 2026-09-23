import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';
import 'package:eClassify/core/utils/log.dart';

/// Backed by [HiveKeys.historyBox], which is opened on demand rather than at
/// boot: search history is only touched once the user opens item search.
///
/// Stores committed search queries (not items) so suggestions re-run a past
/// search rather than jump to a specific item.
class SearchHistoryStorage {
  SearchHistoryStorage._();

  /// Adds [query], moving it to the end (most recent) if already present.
  static Future<bool> addSearchHistory(String query) async {
    try {
      final box = await HiveStorage.ensureOpen(HiveKeys.historyBox);
      final existingKey = box.keys.firstWhere(
        (key) => box.get(key) == query,
        orElse: () => null,
      );
      if (existingKey != null) await box.delete(existingKey);
      await box.add(query);
      return true;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      return false;
    }
  }

  /// Reads stored queries. A box left over from a pre-[String] schema
  /// (queries used to be item JSON maps) is wiped rather than partially
  /// read, since none of that data is a valid query anyway.
  static Future<List<String>> getSearchHistory() async {
    try {
      final values = await HiveStorage.valuesOfAsync(HiveKeys.historyBox);
      return values.cast<String>().toList();
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      await clearSearchHistory();
      return [];
    }
  }

  static Future<void> clearSearchHistory() =>
      HiveStorage.clearBox(HiveKeys.historyBox);
}
