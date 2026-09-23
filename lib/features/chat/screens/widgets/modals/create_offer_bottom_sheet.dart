import 'package:eClassify/core/extensions/currency_extension.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/formatters/currency_formatter.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/surfaces/bottom_sheet_skeleton.dart';
import 'package:flutter/material.dart';

class CreateOfferBottomSheet {
  static Future<String?> show(
    BuildContext context, {
    required String itemPrice,
    required String? currentOffer,
    required Currency? currency,
  }) async {
    return UiUtils.showBottomSheet<String>(
      context,
      child: _SheetContent(
        itemPrice: itemPrice,
        currentOffer: currentOffer,
        currency: currency,
      ),
    );
  }
}

class _SheetContent extends StatefulWidget {
  const _SheetContent({
    required this.itemPrice,
    required this.currentOffer,
    required this.currency,
  });

  final String itemPrice;
  final String? currentOffer;
  final Currency? currency;

  @override
  State<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent> {
  // The current offer arrives server-formatted with its symbol; the field
  // shows the symbol as a fixed affix, so seed it with the bare number.
  late final _controller = TextController(
    text: double.tryParse(
      widget.currentOffer?.normalize(widget.currency) ?? '',
    )?.formatAmount(widget.currency),
  );
  late String _comparableCurrency = _normalizeAmount(widget.itemPrice);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalizeAmount(String text) => text.normalize(widget.currency);

  @override
  Widget build(BuildContext context) {
    return BottomSheetSkeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'makeAnOffer'.translate(context),
            style: context.labelLarge.bold,
          ),
          8.vGap,
          const Divider(),
          16.vGap,
          DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    'sellerPrice'.translate(context),
                    style: context.bodySmall,
                  ),
                  Text(widget.itemPrice, style: context.labelLarge.bold),
                ],
              ),
            ),
          ),
          16.vGap,
          CustomTextField(
            controller: _controller,
            autofocus: true,
            textInputType: TextInputType.number,
            style: context.labelLarge,
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
              // Editing: resubmitting the current amount is a no-op the
              // backend would still record as a new offer message.
              if (widget.currentOffer.isNotNullAndNotEmpty)
                NumericComparisonValidator(
                  getCompareValue: () => widget.currentOffer!,
                  parser: (value) => double.tryParse(_normalizeAmount(value)),
                  operator: ComparisonOperator.notEqualTo,
                  errorText: 'offerSameAsCurrent',
                ),
            ],
          ),
          16.vGap,
          AppButton(
            variant: AppButtonVariant.filled,
            title:
                (widget.currentOffer.isNotNullAndNotEmpty
                        ? 'editOffer'
                        : 'createOffer')
                    .translate(context),
            onPressed: () {
              if (!_controller.validate()) return;
              Navigator.of(context).pop(_controller.text);
            },
          ),
        ],
      ),
    );
  }
}
