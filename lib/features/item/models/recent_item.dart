import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:flutter/foundation.dart';

/// A recently-viewed item, as recorded into search history alongside the
/// query that led to it.
@immutable
class RecentItem {
  RecentItem.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String;

  RecentItem.fromItem(ItemPreview item) : id = item.id, name = item.name;

  final int id;
  final String name;

  Json get toJson => {'id': id, 'name': name};

  @override
  bool operator ==(Object other) => other is RecentItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
