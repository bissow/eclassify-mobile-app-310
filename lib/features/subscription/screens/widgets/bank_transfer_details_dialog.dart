import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

/// Shows the bank's account details for the user to review before
/// confirming they intend to pay via bank transfer. Purely informational —
/// no API calls of its own; the caller drives the payment-intent request
/// once this resolves `true`.
class BankTransferDetailsDialog {
  const BankTransferDetailsDialog._();

  static Future<bool?> show(
    BuildContext context, {
    required BankTransferDetails details,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: Text(
          'bankTransfer'.translate(context),
          style: context.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            _DetailRow(
              label: 'accountHolderName'.translate(context),
              value: details.accountHolderName,
            ),
            _DetailRow(
              label: 'accountNumber'.translate(context),
              value: details.accountNumber,
            ),
            _DetailRow(
              label: 'bankName'.translate(context),
              value: details.bankName,
            ),
            _DetailRow(
              label: 'ifscSwiftCode'.translate(context),
              value: details.ifscSwiftCode,
            ),
          ],
        ),
        negativeButtonLabel: 'cancel'.translate(context),
        positiveButtonLabel: 'confirm'.translate(context),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Text(label, style: context.titleMedium),
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: 40),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: context.colorScheme.surface,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(value, style: context.bodyMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
