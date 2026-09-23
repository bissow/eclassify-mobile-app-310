import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:intl/intl.dart';

extension NumCurrencyExtension on num {
  String currencyFormat([Currency? currency]) {
    final formatted = this.decimalFormat;

    if (currency != null) {
      return NumberFormat.currency(
        name: currency.code,
        symbol: currency.symbol,
      ).format(this);
    }

    return Constant.systemSettings.defaultCurrency.isSymbolOnLeft
        ? '${Constant.systemSettings.defaultCurrency.symbol} $formatted'
        : '$formatted ${Constant.systemSettings.defaultCurrency.symbol}';
  }

  /// Formats with the currency's own separators and decimal places, the
  /// way the backend's `formatted_amount` reads (`20.000,00` for TRY), so
  /// locally built text matches what the server will echo back. Symbol is
  /// optional because inputs show it as a fixed prefix/suffix instead.
  String formatAmount(Currency? currency, {bool withSymbol = false}) {
    final decimalPlaces = (currency?.decimalPlaces ?? 2).toInt();
    final thousandSeparator = currency?.thousandSeparator ?? ',';
    final decimalSeparator = currency?.decimalSeparator ?? '.';

    final fixed = toStringAsFixed(decimalPlaces);
    final dot = fixed.indexOf('.');
    final integerPart = dot == -1 ? fixed : fixed.substring(0, dot);
    final fractionPart = dot == -1 ? '' : fixed.substring(dot + 1);

    final buffer = StringBuffer();
    for (var i = 0; i < integerPart.length; i++) {
      final remaining = integerPart.length - i;
      if (i != 0 && remaining % 3 == 0) buffer.write(thousandSeparator);
      buffer.write(integerPart[i]);
    }
    var formatted = fractionPart.isEmpty
        ? buffer.toString()
        : '$buffer$decimalSeparator$fractionPart';

    if (withSymbol && currency != null) {
      formatted = currency.isSymbolOnLeft
          ? '${currency.symbol} $formatted'
          : '$formatted ${currency.symbol}';
    }
    return formatted;
  }

  String get decimalFormat {
    final supportsLocale = NumberFormat.localeExists(AppSession.currentLocale);
    final numberFormat = NumberFormat.decimalPatternDigits(
      locale: supportsLocale ? AppSession.currentLocale : Intl.defaultLocale,
      decimalDigits: 2,
    );
    return numberFormat.format(this);
  }
}

extension StringCurrencyExtension on String {
  /// Strips a currency-formatted amount down to a plain `1234.56` string:
  /// symbol and thousand separator removed, the currency's decimal
  /// separator replaced by `.`, fraction padded to the currency's decimal
  /// places (`20000` -> `20000.00`). Keeping only `[0-9.]` is not enough —
  /// for a currency like TRY (`20.000,50`) that reads the thousand separator
  /// as a decimal point and turns 20 000 into 20.
  String normalize([Currency? currency]) {
    final thousandSeparator = currency?.thousandSeparator ?? ',';
    final decimalSeparator = currency?.decimalSeparator ?? '.';

    var normalized = this;
    if (currency != null) {
      normalized = normalized.replaceAll(currency.symbol, '');
    }
    if (thousandSeparator.isNotEmpty) {
      normalized = normalized.replaceAll(thousandSeparator, '');
    }
    if (decimalSeparator.isNotEmpty && decimalSeparator != '.') {
      normalized = normalized.replaceAll(decimalSeparator, '.');
    }
    normalized = normalized.replaceAll(RegExp('[^0-9.]'), '');

    final value = double.tryParse(normalized);
    if (value == null) return normalized;
    return value.toStringAsFixed((currency?.decimalPlaces ?? 2).toInt());
  }
}
