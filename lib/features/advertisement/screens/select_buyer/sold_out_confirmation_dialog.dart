import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class SoldOutConfirmationDialog {
  static Future<bool?> show(BuildContext context, bool isJobCategory) async {
    return await showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            isJobCategory
                ? "confirm".translate(context)
                : "confirmSoldOut".translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            isJobCategory
                ? "jobAssignedWarning".translate(context)
                : "soldOutWarning".translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          positiveButtonLabel: 'confirm'.translate(context),
          negativeButtonLabel: 'cancel'.translate(context),
        );
      },
    );
  }
}
