import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AppDialog extends StatelessWidget {
  final Widget? icon;
  final Widget title;
  final Widget? content;

  // Configuration for simple positive/negative buttons
  final String? positiveButtonLabel;
  final VoidCallback? onPositiveTapped;
  final String? negativeButtonLabel;
  final VoidCallback? onNegativeTapped;

  // Fully custom actions list (if provided, configuration buttons are ignored)
  final List<Widget>? actions;

  const AppDialog({
    super.key,
    this.icon,
    required this.title,
    this.content,
    this.positiveButtonLabel,
    this.onPositiveTapped,
    this.negativeButtonLabel,
    this.onNegativeTapped,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      insetPadding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding * 2,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [?icon, title, ?content, 12.vGap, _buildActions(context)],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    if (actions != null) {
      return Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!);
    }

    final hasPositive = positiveButtonLabel != null;
    final hasNegative = negativeButtonLabel != null;

    if (!hasPositive && !hasNegative) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 8,
      children: [
        if (hasNegative)
          Expanded(
            child: AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              backgroundColor: context.colorScheme.surface,
              foregroundColor: context.colorScheme.onSurface,
              onPressed:
                  onNegativeTapped ?? () => Navigator.pop(context, false),
              child: AutoSizeText(
                text: negativeButtonLabel!.translate(context),
                style: context.titleMedium,
                maxLines: 1,
                minimumFontSize: 14,
              ),
            ),
          ),
        if (hasPositive)
          Expanded(
            child: AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              backgroundColor: context.colorScheme.primary,
              onPressed: onPositiveTapped ?? () => Navigator.pop(context, true),
              child: AutoSizeText(
                text: positiveButtonLabel!.translate(context),
                style: context.titleMedium.withColor(
                  context.colorScheme.onPrimary,
                ),
                maxLines: 1,
                minimumFontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}
