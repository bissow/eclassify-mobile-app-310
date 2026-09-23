import 'package:eClassify/core/models/currency.dart';
import 'package:flutter/services.dart';

/// Formats numeric input using a [Currency]'s decimal places, thousand and
/// decimal separators, and optional symbol placement.
class CurrencyFormatter extends TextInputFormatter {
  CurrencyFormatter(this.currency, {this.showSymbol = false});

  final Currency? currency;
  final bool showSymbol;

  static bool _isDigit(String char) =>
      char.isNotEmpty &&
      char.codeUnitAt(0) >= 0x30 &&
      char.codeUnitAt(0) <= 0x39;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final decimalPlaces = (currency?.decimalPlaces ?? 2).toInt();
    final thousandSeparator = currency?.thousandSeparator ?? ',';
    final decimalSeparator = currency?.decimalSeparator ?? '.';

    if (newValue.text.isEmpty) return newValue;

    // strip currency symbol first so its glyphs (e.g. "د.إ" contains ".")
    // never get mistaken for digits/separators below
    var rawText = newValue.text;
    if (currency != null) {
      rawText = rawText.replaceAll(currency!.symbol, '');
    }

    // keep digits and single decimal separator only
    final decimalSepEscaped = RegExp.escape(decimalSeparator);
    var digits = rawText.replaceAll(RegExp('[^0-9$decimalSepEscaped]'), '');

    final firstSepIndex = digits.indexOf(decimalSeparator);
    var integerPart = firstSepIndex == -1
        ? digits
        : digits.substring(0, firstSepIndex);
    var fractionPart = firstSepIndex == -1
        ? ''
        : digits
              .substring(firstSepIndex + decimalSeparator.length)
              .replaceAll(decimalSeparator, '');

    if (decimalPlaces <= 0) {
      fractionPart = '';
    } else if (fractionPart.length > decimalPlaces) {
      fractionPart = fractionPart.substring(0, decimalPlaces);
    }

    integerPart = integerPart.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    // Nothing numeric left (e.g. only the symbol survived a select-all
    // delete): clear the field instead of leaving a phantom "0" that the
    // next keystroke appends to, turning "2" into "20".
    if (integerPart.isEmpty && fractionPart.isEmpty && firstSepIndex == -1) {
      return TextEditingValue.empty;
    }

    final buffer = StringBuffer();
    for (int i = 0; i < integerPart.length; i++) {
      final remaining = integerPart.length - i;
      if (i != 0 && remaining % 3 == 0) buffer.write(thousandSeparator);
      buffer.write(integerPart[i]);
    }
    var formattedInteger = buffer.toString();
    if (formattedInteger.isEmpty) formattedInteger = '0';

    final hasTrailingSeparator =
        firstSepIndex != -1 && fractionPart.isEmpty && decimalPlaces > 0;

    var formatted = hasTrailingSeparator
        ? '$formattedInteger$decimalSeparator'
        : (fractionPart.isEmpty
              ? formattedInteger
              : '$formattedInteger$decimalSeparator$fractionPart');

    if (currency != null && showSymbol) {
      formatted = currency!.isSymbolOnLeft
          ? '${currency!.symbol} $formatted'
          : '$formatted ${currency!.symbol}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _cursorOffsetFor(newValue, formatted),
      ),
    );
  }

  /// Preserves cursor position across reformatting by counting digits
  /// left of the cursor in the raw input and re-anchoring after the same
  /// digit count in the formatted output. Straight `offset: end` breaks
  /// mid-string edits (backspace, insert) especially with bidi symbols
  /// like "د.إ" where "end of string" isn't visually where the cursor was.
  int _cursorOffsetFor(TextEditingValue newValue, String formatted) {
    final cursorOffset = newValue.selection.baseOffset;
    final atEnd = cursorOffset < 0 || cursorOffset >= newValue.text.length;
    if (atEnd) return formatted.length;

    var digitsBeforeCursor = 0;
    for (var i = 0; i < cursorOffset; i++) {
      if (_isDigit(newValue.text[i])) digitsBeforeCursor++;
    }

    if (digitsBeforeCursor == 0) {
      final firstDigitIndex = formatted.indexOf(RegExp(r'[0-9]'));
      return firstDigitIndex == -1 ? 0 : firstDigitIndex;
    }

    var seen = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (_isDigit(formatted[i])) {
        seen++;
        if (seen == digitsBeforeCursor) return i + 1;
      }
    }
    return formatted.length;
  }
}
