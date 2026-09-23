import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/auth/models/user.dart';

class AuthStorage {
  AuthStorage._();

  static String? getJWT() =>
      HiveStorage.read<String>(HiveKeys.userDetailsBox, HiveKeys.jwtToken);

  static void setJWT(String token) async {
    await HiveStorage.write(
      HiveKeys.userDetailsBox,
      HiveKeys.jwtToken,
      token,
    );
  }

  static User? getUser() {
    _migrateLegacyUser();
    final raw = HiveStorage.read<Map>(
      HiveKeys.userDetailsBox,
      HiveKeys.userKey,
    );
    if (raw.isNullOrEmpty) return null;
    try {
      return User.fromJson(raw!.cast<String, dynamic>());
    } catch (e, s) {
      // Corrupt user record — treat like a forced logout and wipe the whole
      // box (same as [clearSession] on sign-out) so no half-alive session,
      // stale jwt, or polluting key survives to crash the next read.
      Log.error('getUser parse failed, clearing session box', e, s);
      HiveStorage.clearBox(HiveKeys.userDetailsBox);
      return null;
    }
  }

  static void setUser(Map data) async {
    await HiveStorage.write(HiveKeys.userDetailsBox, HiveKeys.userKey, data);
  }

  /// Wipes every box tied to the signed-in session. Referenced by
  /// `LeafLocationCubit.clearSessionState`, which relies on the `location`
  /// key living in [HiveKeys.userDetailsBox] and being cleared here.
  static Future<void> clearSession() async {
    await HiveStorage.clearBox(HiveKeys.userDetailsBox);
    await HiveStorage.clearBox(HiveKeys.historyBox);
  }

  /// Reserved sibling keys in [HiveKeys.userDetailsBox] that are NOT user
  /// fields. Everything else at the top level is legacy flat user data.
  static const _reservedBoxKeys = {
    HiveKeys.userKey,
    HiveKeys.jwtToken,
    HiveKeys.locationKey,
  };

  // TODO(2027-02-14): Remove this migration. By this date, v3.0 (which
  // introduced the nested userKey format) will have been out long enough
  // that any install still on the flat format hasn't been opened in 6+
  // months.
  /// One-time upgrade: pre-v3.0 stored user fields flat across the box
  /// (via `putAll`). Collect those into a single map under [HiveKeys.userKey]
  /// and strip the loose keys so they can never masquerade as user data again.
  static void _migrateLegacyUser() {
    const box = HiveKeys.userDetailsBox;
    if (HiveStorage.readKey(box, HiveKeys.userKey) != null) {
      return; // already new format
    }
    final legacy = <String, dynamic>{};
    for (final key in HiveStorage.keysOf(box)) {
      if (key is String && _reservedBoxKeys.contains(key)) continue;
      legacy[key.toString()] = HiveStorage.readKey(box, key);
    }
    if (legacy['id'] == null) return; // no real legacy user present
    HiveStorage.write(box, HiveKeys.userKey, legacy);
    HiveStorage.deleteAll(box, legacy.keys);
  }
}
