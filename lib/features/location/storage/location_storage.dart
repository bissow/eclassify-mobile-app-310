import 'package:eClassify/core/storage/hive_keys.dart';
import 'package:eClassify/core/storage/hive_storage.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';

class LocationStorage {
  LocationStorage._();

  static LeafLocation? getLocation() {
    final json = HiveStorage.readJson(
      HiveKeys.userDetailsBox,
      HiveKeys.locationKey,
    );
    return json != null ? LeafLocation.fromJson(json) : null;
  }

  static void setLocation({required LeafLocation location}) {
    HiveStorage.write(
      HiveKeys.userDetailsBox,
      HiveKeys.locationKey,
      location.toJson,
    );
  }
}
