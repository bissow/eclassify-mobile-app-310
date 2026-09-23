import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class LoginRequiredBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(context: context, builder: (_) => _SheetContent());
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'loginRequiredForFeature'.translate(context),
              style: context.titleMedium,
            ),
            5.vGap,
            Text(
              'loginToAuthorizePrompt'.translate(context),
              style: context.bodyMedium,
            ),
            10.vGap,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppButton(
                variant: AppButtonVariant.filled,
                size: AppButtonSize.compact,
                width: AppButtonWidth.content,
                onPressed: () {
                  Navigator.popAndPushNamed(context, Routes.auth);
                },
                title: 'loginNow',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
