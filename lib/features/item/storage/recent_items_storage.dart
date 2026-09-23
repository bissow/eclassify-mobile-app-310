import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/recent_item.dart';

/// Backed by [HiveKeys.recentItemsBox], which is opened on demand rather
/// than at boot: recent items are only touched once the user opens item
/// search.
///
/// Stores items the user opened from search results, alongside
/// [SearchHistoryStorage]'s query history — search suggestions show both.
class RecentItemsStorage {
  RecentItemsStorage._();

  /// Adds [item], moving it to the end (most recent) if already present.
  static Future<bool> addRecentItem(RecentItem item) async {
    try {
      final box = await HiveStorage.ensureOpen(HiveKeys.recentItemsBox);
      final existingKey = box.keys.firstWhere(
        (key) => RecentItem.fromJson(box.get(key)).id == item.id,
        orElse: () => null,
      );
      if (existingKey != null) await box.delete(existingKey);
      await box.add(item.toJson);
      return true;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      return false;
    }
  }

  /// Reads stored items, wiping the box on an incompatible legacy schema
  /// rather than partially reading it.
  static Future<List<RecentItem>> getRecentItems() async {
    try {
      final jsonList = await HiveStorage.valuesOfAsync(
        HiveKeys.recentItemsBox,
      );
      return jsonList.map((e) => RecentItem.fromJson(e)).toList();
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      await clearRecentItems();
      return [];
    }
  }

  static Future<void> clearRecentItems() =>
      HiveStorage.clearBox(HiveKeys.recentItemsBox);
}
