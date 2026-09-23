import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/models/localized_string.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class FeaturedSection {
  FeaturedSection.fromJson(Json json)
    : id = json['id'] as int,
      title = LocalizedString(
        canonical: json['title'] as String,
        translated: json['translated_name'] as String,
      ),
      style = json['style'] as String,
      items = JsonHelper.parseList(
        json['section_data'] as List?,
        ItemPreview.fromJson,
      );

  final int id;
  final LocalizedString title;
  final String style;
  final List<ItemPreview> items;
}
