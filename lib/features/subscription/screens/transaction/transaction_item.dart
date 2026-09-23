import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/subscription/models/transaction.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class TransactionItem extends StatelessWidget {
  const TransactionItem({
    required this.transaction,
    required this.onUploadReceipt,
    super.key,
  });

  final Transaction transaction;
  final VoidCallback onUploadReceipt;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Row(
                        spacing: 8,
                        children: [
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.colorScheme.primary.withValues(
                                alpha: .1,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 1,
                                horizontal: 4,
                              ),
                              child: Text(
                                transaction.paymentGateway.capitalize,
                                style: context.labelMedium.withColor(
                                  context.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          if (transaction.isBankTransfer &&
                              transaction.status == PaymentStatus.pending &&
                              !transaction.hasUploadedReceipt)
                            AppButton(
                              variant: AppButtonVariant.outlined,
                              size: AppButtonSize.compact,
                              width: AppButtonWidth.content,
                              textStyle: context.labelSmall,
                              style: ButtonStyle(
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: onUploadReceipt,
                              title: 'uploadReceipt',
                            ),
                        ],
                      ),
                      Text(transaction.orderId, style: context.bodyMedium),
                      Text(
                        transaction.date.format(),
                        style: context.bodySmall.withColor(context.mutedColor),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 4,
                  children: [
                    Text(
                      transaction.formattedAmount,
                      style: context.bodyMedium.withColor(
                        context.colorScheme.primary,
                      ),
                    ),
                    Text(
                      transaction.status.label.translate(context),
                      style: context.bodySmall,
                    ),
                    if (transaction.status == PaymentStatus.succeed)
                      AppButton(
                        variant: AppButtonVariant.outlined,
                        size: AppButtonSize.compact,
                        width: AppButtonWidth.content,
                        textStyle: context.labelSmall,
                        style: ButtonStyle(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.transactionReceipt,
                            arguments: {
                              "transactionId": transaction.id,
                              'transactionOrderId': transaction.orderId,
                            },
                          );
                        },
                        title: 'receipt',
                      ),
                  ],
                ),
              ],
            ),
          ),
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: transaction.status.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const SizedBox(width: 3),
            ),
          ),
        ],
      ),
    );
  }
}
