import 'package:eClassify/core/utils/json_helper.dart';

class Currency {
  Currency.fromJson(Json json)
    : id = json['id'] as int?,
      code = json['iso_code'] as String? ?? '',
      symbol = json['symbol'] as String,
      isSymbolOnLeft =
          (json['position'] as String? ?? json['symbol_position'] as String?) ==
          'left',
      selected = (json['selected'] as int?) == 1,
      decimalPlaces = num.tryParse(json['decimal_places'].toString()),
      thousandSeparator = json['thousand_separator'] as String?,
      decimalSeparator = json['decimal_separator'] as String?;

  final int? id;
  final String code;
  final String symbol;
  final bool isSymbolOnLeft;
  final bool selected;
  final num? decimalPlaces;
  final String? thousandSeparator;
  final String? decimalSeparator;
}
