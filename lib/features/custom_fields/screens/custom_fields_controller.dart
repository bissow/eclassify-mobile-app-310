import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/custom_fields/models/custom_field_value.dart';
import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:flutter/material.dart';

class CustomFieldsController {
  final MapNotifier<int, String> _errors = MapNotifier();

  MapNotifier<int, String> get errorNotifier => _errors;

  final Map<int, CustomFieldValue> _values = Map();

  Map<int, CustomFieldValue> get data => _values;

  /// Id of the field that should scroll itself into view. Set by
  /// [revealFirstError]; the field's [CustomFieldSkeleton] listens, scrolls,
  /// and resets it to null so the same field can be revealed again. Keeps
  /// widget contexts out of this controller.
  final ValueNotifier<int?> revealNotifier = ValueNotifier(null);

  /// First invalid field in registration (= layout) order — not `_errors`
  /// iteration order, which follows when each error was last written.
  int? get firstErrorId {
    for (final id in _values.keys) {
      if (_errors.containsKey(id)) return id;
    }
    return null;
  }

  /// Scrolls the first invalid field into view. Call after a failed
  /// [validate] so a long form doesn't leave the user guessing why "next"
  /// does nothing.
  void revealFirstError() {
    revealNotifier.value = firstErrorId;
  }

  void registerFields(
    List<CustomField> fields, {
    Map<int, dynamic>? initialValues,
    bool assignValidators = true,
    bool isDefaultLanguage = true,
  }) {
    for (final field in fields) {
      final validators = assignValidators
          ? [
              if (field.isRequired && isDefaultLanguage) EmptyFieldValidator(),
              // No isDefaultLanguage guard needed here: TextLengthValidator
              // treats null/empty as valid and only checks min/max on a
              // non-empty value, so a blank translation always passes.
              // Enforcing "not blank" is EmptyFieldValidator's job above.
              if (field case final TextboxField field)
                TextLengthValidator(min: field.minLength, max: field.maxLength),
            ]
          : <Validator>[];
      _values[field.id] = CustomFieldValue(
        field: field,
        value: initialValues?[field.id],
        validators: validators,
      );
    }
  }

  void updateValue(int id, dynamic value) {
    _values[id] = _values[id]!.updateValue(value: value);
  }

  bool validate() {
    bool isValid = true;
    for (final value in _values.values) {
      _errors.remove(value.field.id);
      isValid &= _validateField(value);
    }
    return isValid;
  }

  bool _validateField(CustomFieldValue value) {
    for (final validator in value.validators) {
      final stringValue = switch (value.value) {
        final String s => s,
        final List l => l.join(','),
        final FileResource r => r.filePath,
        _ => null,
      };
      if (!validator.validate(stringValue)) {
        _errors.put(value.field.id, validator.errorText);
        return false;
      }
    }
    return true;
  }

  void clear() {
    _values.clear();
    _errors.clear();
    revealNotifier.value = null;
  }
}

///A provider class to inject the [CustomFieldsController] instance
///to all the field widgets inside the [DynamicForm] widget so that all the field widgets
///can update their values when user interacts with it.

class CustomFieldsControllerProvider extends InheritedWidget {
  const CustomFieldsControllerProvider({
    required this.controller,
    this.isDefaultLanguage = true,
    required super.child,
    super.key,
  });

  final CustomFieldsController controller;
  final bool isDefaultLanguage;

  static CustomFieldsControllerProvider? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CustomFieldsControllerProvider>();
  }

  @override
  bool updateShouldNotify(covariant CustomFieldsControllerProvider oldWidget) =>
      oldWidget.controller != controller ||
      oldWidget.isDefaultLanguage != isDefaultLanguage;
}
