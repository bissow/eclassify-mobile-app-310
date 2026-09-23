import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class FreePackagePurchaseDialog {
  static Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'freePackagePurchaseTitle'.translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'freePackagePurchaseDescription'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          onNegativeTapped: () => Navigator.of(context).pop(false),
          positiveButtonLabel: 'confirm'.translate(context),
          onPositiveTapped: () => Navigator.of(context).pop(true),
        );
      },
    );
  }
}
