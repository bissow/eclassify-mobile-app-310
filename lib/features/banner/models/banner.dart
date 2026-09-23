import 'package:eClassify/features/banner/models/banner_action.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class Banner {
  Banner.fromJson(Json json)
    : image = json['image'] as String,
      action = BannerAction.parse(json);

  final String image;
  final BannerAction action;
}
