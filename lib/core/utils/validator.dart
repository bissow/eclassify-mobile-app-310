import 'package:eClassify/core/extensions/generic_extensions.dart';

///Base class for Custom Validation rules
abstract class Validator<T> {
  Validator({required this.errorText});

  final String errorText;

  bool validate(T value);
}

class EmptyFieldValidator extends Validator<String?> {
  EmptyFieldValidator({super.errorText = 'fieldMustNotBeEmpty'});

  @override
  bool validate(String? value) {
    return value.isNotNullAndNotEmpty;
  }
}

class SlugValidator extends Validator<String?> {
  SlugValidator({super.errorText = 'invalidSlug'});

  final slugRegex = RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$');

  @override
  bool validate(String? value) {
    if (value.isNullOrEmpty) return true;
    return slugRegex.hasMatch(value!);
  }
}

enum ComparisonOperator {
  lessThan,
  lessThanOrEqualTo,
  greaterThan,
  greaterThanOrEqualTo,
  notEqualTo,
}

class NumericComparisonValidator extends Validator<String?> {
  NumericComparisonValidator({
    required this.getCompareValue,
    required this.operator,
    required super.errorText,
    double? Function(String)? parser,
  }) : parser = parser ?? double.tryParse;

  final String Function() getCompareValue;
  final ComparisonOperator operator;

  /// Parses a value before comparing. Override to strip currency
  /// symbols/separators when the
  /// field text isn't plain numeric.
  final double? Function(String) parser;

  @override
  bool validate(String? value) {
    if (value.isNullOrEmpty) return true;
    final val = parser(value!);
    final compareVal = parser(getCompareValue());

    // Let EmptyFieldValidator handle empty states; don't fail comparison on nulls
    if (val == null || compareVal == null) return true;

    switch (operator) {
      case ComparisonOperator.lessThan:
        return val < compareVal;
      case ComparisonOperator.lessThanOrEqualTo:
        return val <= compareVal;
      case ComparisonOperator.notEqualTo:
        return val != compareVal;
      case ComparisonOperator.greaterThan:
        return val > compareVal;
      case ComparisonOperator.greaterThanOrEqualTo:
        return val >= compareVal;
    }
  }
}

class TextLengthValidator extends Validator<String?> {
  TextLengthValidator({
    required this.min,
    required this.max,
    super.errorText = 'invalidLength',
  });

  final int? min;
  final int? max;

  @override
  bool validate(String? value) {
    if (value.isNullOrEmpty) return true;
    if (min != null && value!.length < min!) return false;
    if (max != null && value!.length > max!) return false;
    return true;
  }
}

class EmailValidator extends Validator<String?> {
  EmailValidator({super.errorText = 'invalidEmail'});

  static final _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );

  @override
  bool validate(String? value) {
    // Empty State should be handled by EmptyFieldValidator
    if (value.isNullOrEmpty) return true;
    return _emailRegex.hasMatch(value!);
  }
}

class CallbackValidator<T> extends Validator<T> {
  CallbackValidator({
    super.errorText = 'fieldMustNotBeEmpty',
    required this.predicate,
  });

  final bool Function(T value) predicate;

  @override
  bool validate(T value) => predicate(value);
}
