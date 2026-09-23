import 'package:eClassify/core/models/localized_string.dart';
import 'package:eClassify/features/custom_fields/enums/custom_field_type.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:flutter/foundation.dart';

@immutable
base class CustomField {
  factory CustomField.parse(Json json) {
    final type = CustomFieldType.parse(json['type'] as String);
    return switch (type) {
      CustomFieldType.radio => RadioField.fromJson(json),
      CustomFieldType.textbox => TextInputField.fromJson(json),
      CustomFieldType.number => NumberInputField.fromJson(json),
      CustomFieldType.checkbox => CheckboxField.fromJson(json),
      CustomFieldType.dropdown => DropdownField.fromJson(json),
      CustomFieldType.file => FileInputField.fromJson(json),
      _ => throw UnimplementedError('Unknown custom field type: $type'),
    };
  }

  CustomField._fromJson(Json json)
    : id = json['id'] as int,
      name = LocalizedString(
        canonical: json['name'] as String,
        translated: json['translated_name'] as String?,
      ),
      image = json['image'] as String? ?? '',
      isRequired = ((json['required'] ?? json['is_required']) as int?) == 1;

  final int id;
  final LocalizedString name;
  final String image;
  final bool isRequired;

  @override
  bool operator ==(Object other) => other is CustomField && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

base class TextboxField extends CustomField {
  TextboxField.fromJson(super.json)
    : minLength = json['min_length'] as int?,
      maxLength = json['max_length'] as int?,
      super._fromJson();

  final int? minLength;
  final int? maxLength;
}

final class TextInputField extends TextboxField {
  TextInputField.fromJson(super.json) : super.fromJson();
}

final class NumberInputField extends TextboxField {
  NumberInputField.fromJson(super.json) : super.fromJson();
}

base class SelectionField extends CustomField {
  SelectionField.fromJson(super.json)
    : values = _getValues(json['values'], json['translated_value']),
      super._fromJson();

  final List<LocalizedString> values;

  static List<LocalizedString> _getValues(
    List<dynamic> values,
    List<dynamic> translatedValues,
  ) {
    final List<LocalizedString> localizedValues = [];
    values = values.cast<String>();
    translatedValues = translatedValues.cast<String>();
    for (int i = 0; i < values.length; i++) {
      final canonical = values[i];
      final translated = i < translatedValues.length
          ? translatedValues[i]
          : null;
      localizedValues.add(
        LocalizedString(canonical: canonical, translated: translated),
      );
    }
    return localizedValues;
  }
}

final class CheckboxField extends SelectionField {
  CheckboxField.fromJson(super.json) : super.fromJson();
}

final class RadioField extends SelectionField {
  RadioField.fromJson(super.json) : super.fromJson();
}

final class DropdownField extends SelectionField {
  DropdownField.fromJson(super.json) : super.fromJson();
}

final class FileInputField extends CustomField {
  FileInputField.fromJson(super.json) : super._fromJson();
}
