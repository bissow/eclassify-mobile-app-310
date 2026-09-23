import 'dart:ui';

import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class Language {
  Language.fromJson(Json json)
    : id = json['id'] as int,
      languageCode = json['code'] as String,
      countryCode = json['country_code'] as String? ?? 'US',
      name = json['name'] as String,
      englishName = json['name_in_english'] as String,
      isRTL = json['rtl'] as bool,
      image = json['image'] as String;

  final int id;
  final String languageCode;
  final String countryCode;
  final String name;
  final String englishName;
  final bool isRTL;
  final String image;

  bool get isDefault =>
      Constant.systemSettings.defaultLanguageCode.toLowerCase() ==
      languageCode.toLowerCase();

  String get localeString =>
      '${languageCode.toLowerCase()}_${countryCode.toUpperCase()}';

  Locale get locale => Locale(languageCode, countryCode);

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': languageCode,
    'country_code': countryCode,
    'name': name,
    'name_in_english': englishName,
    'rtl': isRTL,
    'image': image,
  };
}
