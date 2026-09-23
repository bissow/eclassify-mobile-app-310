import 'package:hive/hive.dart';

/// Thin, domain-agnostic wrapper over Hive boxes.
///
/// Deliberately knows nothing about [User], [LeafLocation], or any other
/// model: typed accessors belong to the feature that owns the data, so that
/// core never has to import a feature. See `AuthStorage`, `LocationStorage`,
/// `SearchHistoryStorage`, and `OnboardingStorage`.
class HiveStorage {
  HiveStorage._();

  static T? read<T>(String box, String key) => Hive.box(box).get(key) as T?;

  /// Reads a JSON map, normalising Hive's untyped `Map` into
  /// `Map<String, dynamic>`. Returns null when absent or not a map.
  static Map<String, dynamic>? readJson(String box, String key) =>
      (Hive.box(box).get(key) as Map?)?.cast<String, dynamic>();

  static Future<void> write(String box, String key, Object? value) =>
      Hive.box(box).put(key, value);

  static Future<void> delete(String box, String key) =>
      Hive.box(box).delete(key);

  static Future<void> deleteAll(String box, Iterable<dynamic> keys) =>
      Hive.box(box).deleteAll(keys);

  /// Returns the box, opening it first if it is not already open.
  ///
  /// Boxes on the boot critical path are opened eagerly in `_initializeHive`;
  /// on-demand boxes such as [HiveKeys.historyBox] are not, so anything
  /// touching those must go through here rather than [Hive.box], which
  /// throws when the box is closed.
  static Future<Box> ensureOpen(String box) async =>
      Hive.isBoxOpen(box) ? Hive.box(box) : await Hive.openBox(box);

  static Future<void> clearBox(String box) async =>
      (await ensureOpen(box)).clear();

  /// [valuesOf] for boxes that may not be open yet.
  static Future<List<dynamic>> valuesOfAsync(String box) async =>
      (await ensureOpen(box)).values.toList();

  /// [addAll] for boxes that may not be open yet.
  static Future<void> addAsync(String box, dynamic value) async {
    await (await ensureOpen(box)).add(value);
  }

  static Iterable<dynamic> keysOf(String box) => Hive.box(box).keys;

  /// Reads by a raw Hive key, which may be a non-String (Hive auto-increment
  /// keys are ints). Used by the legacy user migration.
  static Object? readKey(String box, Object? key) => Hive.box(box).get(key);
}
