import 'package:eClassify/core/extensions/currency_extension.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/formatters/currency_formatter.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:flutter/material.dart';

class CreateOfferDialog {
  static Future<double?> show(
    BuildContext context, {
    required String formattedPrice,
    Currency? currency,
  }) {
    return showDialog<double>(
      context: context,
      builder: (context) {
        return _CreateOfferDialogContent(
          formattedPrice: formattedPrice,
          currency: currency,
        );
      },
    );
  }
}

class _CreateOfferDialogContent extends StatefulWidget {
  const _CreateOfferDialogContent({
    required this.formattedPrice,
    this.currency,
  });

  final String formattedPrice;
  final Currency? currency;

  @override
  State<_CreateOfferDialogContent> createState() =>
      _CreateOfferDialogContentState();
}

class _CreateOfferDialogContentState extends State<_CreateOfferDialogContent> {
  final _controller = TextController();
  late String _comparableCurrency = _normalizeAmount(widget.formattedPrice);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalizeAmount(String text) => text.normalize(widget.currency);

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: Text('makeAnOffer'.translate(context), style: context.titleLarge),
      content: Column(
        children: [
          const Divider(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'sellerPrice'.translate(context),
                  style: context.titleMedium.withColor(context.mutedColor),
                ),
                TextSpan(
                  text: ' : ${widget.formattedPrice}',
                  style: context.titleMedium.bold,
                ),
              ],
            ),
          ),
          16.vGap,
          CustomTextField(
            controller: _controller,
            autofocus: true,
            textInputType: TextInputType.number,
            textAlign: TextAlign.center,
            style: context.titleLarge,
            filled: true,
            fillColor: context.colorScheme.surface,
            formatters: [CurrencyFormatter(widget.currency)],
            prefixText: widget.currency?.isSymbolOnLeft == true
                ? widget.currency!.symbol
                : null,
            suffixText: widget.currency?.isSymbolOnLeft == false
                ? widget.currency!.symbol
                : null,
            validators: [
              EmptyFieldValidator(),
              NumericComparisonValidator(
                getCompareValue: () => _comparableCurrency,
                parser: (value) => double.tryParse(_normalizeAmount(value)),
                operator: ComparisonOperator.lessThan,
                errorText: 'offerPriceWarning',
              ),
              NumericComparisonValidator(
                getCompareValue: () => '0.0',
                parser: (value) => double.tryParse(_normalizeAmount(value)),
                operator: ComparisonOperator.greaterThan,
                errorText: 'valueMustBeGreaterThanZero',
              ),
            ],
          ),
        ],
      ),
      positiveButtonLabel: 'send'.translate(context),
      onPositiveTapped: () {
        if (!_controller.validate()) return;
        final offer = double.parse(_normalizeAmount(_controller.text));
        Navigator.of(context).pop(offer);
      },
      negativeButtonLabel: 'cancel'.translate(context),
      onNegativeTapped: () {
        Navigator.of(context).pop();
      },
    );
  }
}
