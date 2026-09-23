import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/custom_fields/screens/widgets/checkbox_selection_widget.dart';
import 'package:eClassify/features/custom_fields/screens/widgets/custom_field_skeleton.dart';
import 'package:eClassify/features/custom_fields/screens/widgets/dropdown_selection_widget.dart';
import 'package:eClassify/features/custom_fields/screens/widgets/file_input_widget.dart';
import 'package:eClassify/features/custom_fields/screens/widgets/radio_selection_widget.dart';
import 'package:eClassify/features/custom_fields/screens/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';

class CustomFieldsWidgetFactory {
  static Widget createField(CustomField field) {
    final child = switch (field) {
      final RadioField field => RadioSelectionWidget(field: field),
      final TextInputField field => TextFieldWidget(field: field),
      final NumberInputField field => TextFieldWidget(field: field),
      final CheckboxField field => CheckboxSelectionWidget(field: field),
      final DropdownField field => DropdownSelectionWidget(field: field),
      final FileInputField field => FileInputWidget(field: field),
      _ => throw UnimplementedError('Unknown custom field type: $field'),
    };

    return CustomFieldSkeleton(field: field, child: child);
  }
}
