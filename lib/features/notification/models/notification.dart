import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class Notification {
  Notification.fromJson(Json json)
    : id = json['id'] as int,
      title = json['title'] as String,
      description = json['message'] as String,
      image = json['image'] as String?,
      date = DateTime.parse(json['created_at'] as String),
      item = JsonHelper.parseObjectOrNull(
        json['item'] as Json?,
        ItemPreview.fromJson,
      );

  final int id;
  final String title;
  final String description;
  final String? image;
  final DateTime date;
  final ItemPreview? item;
}
