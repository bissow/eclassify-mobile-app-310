import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/core/utils/validator.dart';

class CustomFieldValue {
  CustomFieldValue({
    required this.field,
    required this.value,
    required this.validators,
  });

  final CustomField field;
  final dynamic value;
  final List<Validator> validators;

  CustomFieldValue updateValue({required dynamic value}) =>
      CustomFieldValue(field: field, value: value, validators: validators);

  @override
  String toString() {
    return 'CustomFieldValue{field: $field, value: $value, validators: $validators}';
  }
}
