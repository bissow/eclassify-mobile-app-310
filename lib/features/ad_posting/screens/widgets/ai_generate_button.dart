import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';

class AIGenerateButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AIGenerateButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if AI is enabled in system settings
    if (!(Constant.systemSettings.geminiAiEnabled)) {
      return const SizedBox.shrink();
    }

    return AppButton(
      size: AppButtonSize.compact,
      variant: AppButtonVariant.outlined,
      width: AppButtonWidth.content,
      onPressed: onPressed,
      icon: const Icon(AppIcons.sparkleFill, size: 18),
      title: isLoading ? 'generating' : 'generateWithAi',
    );
  }
}
