import 'package:flutter/services.dart';

/// Normalises free text into a URL slug as the user types: lowercase,
/// non-alphanumerics collapsed to single hyphens.
///
/// Deliberately generic and free of any item/ad domain rules. The backend
/// owns the actual slug contract, including uniqueness — it appends a random
/// suffix when a slug already exists — so this only mirrors the character
/// rules for immediate feedback in the field.
class SlugFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text;

    // force lowercase
    text = text.toLowerCase();

    // replace non-alphanumeric with "-"
    text = text.replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    // collapse multiple "-"
    text = text.replaceAll(RegExp(r'-{2,}'), '-');

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
