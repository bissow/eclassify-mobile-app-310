import 'package:eClassify/core/utils/log.dart';

typedef Json = Map<String, dynamic>;
typedef FromJson<T> = T Function(Json);
typedef Serializer<T, S> = T Function(S value);

class JsonHelper {
  static T parseObject<T>(Json json, FromJson<T> fromJson) {
    return fromJson.call(json);
  }

  static T? parseObjectOrNull<T>(Json? json, FromJson<T> fromJson) {
    if (json == null) return null;
    return fromJson.call(json);
  }

  static List<T> parseList<T>(List<dynamic>? jsonList, FromJson<T> fromJson) {
    if (jsonList == null || jsonList.isEmpty) return const [];

    if (jsonList.any((element) => element is! Json)) {
      throw FormatException('Expected List<Json>, instead got $jsonList');
    }

    final list = jsonList.cast<Json>().map(fromJson).toList();
    return list;
  }

  static List<T> serializeList<T, S>(
    List<S>? list,
    Serializer<T, S> serializer,
  ) {
    if (list == null || list.isEmpty) return <T>[];
    try {
      return list.map(serializer).toList();
    } catch (e, stack) {
      Log.error(e.toString(), e, stack);
      throw FormatException('Failed to serialize list from $S to $T: $e');
    }
  }
}
