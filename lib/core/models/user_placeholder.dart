import 'package:eClassify/core/utils/json_helper.dart';

class UserPlaceholder {
  UserPlaceholder.fromJson(Json json)
    : initial = json['initial'] as String?,
      avatarColor = json['avatar_color'] as String?;

  final String? initial;
  final String? avatarColor;

  Json toJson() {
    return {'initial': initial, 'avatar_color': avatarColor};
  }
}
