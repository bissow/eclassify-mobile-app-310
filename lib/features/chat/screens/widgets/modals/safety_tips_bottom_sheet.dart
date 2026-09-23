import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/surfaces/bottom_sheet_skeleton.dart';
import 'package:flutter/material.dart';

class SafetyTipsBottomSheet {
  static Future<bool> show(
    BuildContext context, {
    required List<String> tips,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      backgroundColor: context.colorScheme.secondary,
      builder: (context) => _SafetyTipsBottomSheetContent(tips: tips),
    );
    return result ?? false;
  }
}

class _SafetyTipsBottomSheetContent extends StatelessWidget {
  const _SafetyTipsBottomSheetContent({required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    return BottomSheetSkeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 10,
        children: [
          Text(
            'safetyTips'.translate(context),
            style: context.titleMedium.bold,
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: tips.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      AppIcons.checkCircleFill,
                      size: 18,
                      color: context.colorScheme.primary,
                    ),
                    8.hGap,
                    Expanded(child: Text(tips[index])),
                  ],
                );
              },
            ),
          ),
          AppButton(
            variant: AppButtonVariant.filled,
            size: AppButtonSize.small,
            onPressed: () => Navigator.of(context).pop(true),
            title: 'continueToOffer',
          ),
        ],
      ),
    );
  }
}
