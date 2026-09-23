import 'package:eClassify/core/models/user_placeholder.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class UserPreview {
  UserPreview({
    required this.id,
    required this.name,
    this.profile,
    this.placeholder,
  });

  UserPreview.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      profile = json['profile'] as String?,
      placeholder = UserPlaceholder.fromJson(json);

  final int id;
  final String name;
  final String? profile;
  final UserPlaceholder? placeholder;
}
