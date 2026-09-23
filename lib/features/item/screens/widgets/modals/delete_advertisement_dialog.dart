import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class DeleteAdvertisementDialog {
  static Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            "deleteAdvertisementTitle".translate(context),
            style: context.titleMedium,
          ),
          content: Text(
            "deleteAdvertisementDescription".translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          positiveButtonLabel: 'delete'.translate(context),
        );
      },
    );
  }
}
