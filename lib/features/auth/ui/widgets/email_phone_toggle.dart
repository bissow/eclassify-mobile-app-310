import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

/// true => Email
/// false => Phone
class EmailPhoneToggle extends StatelessWidget {
  const EmailPhoneToggle({
    required this.notifier,
    required this.isBusy,
    super.key,
  });

  final ValueNotifier<bool> notifier;
  final ValueNotifier<bool> isBusy;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, isEmailLogin, child) {
        final label = isEmailLogin ? 'continueWithPhone' : 'continueWithEmail';
        final icon = isEmailLogin ? AppIcons.phone : AppIcons.envelopeSimple;
        return AppButton(
          variant: AppButtonVariant.filled,
          backgroundColor: context.colorScheme.secondary,
          foregroundColor: context.colorScheme.onSecondary,
          onPressed: () {
            if (isBusy.value) return;
            notifier.value = !isEmailLogin;
          },
          title: label,
          icon: Icon(icon),
        );
      },
    );
  }
}
