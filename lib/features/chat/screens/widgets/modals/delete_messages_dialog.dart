import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:flutter/material.dart';

class DeleteMessagesDialog {
  static Future<bool?> show(BuildContext context, {required int count}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            "${"delete".translate(context)} $count ${"messages".translate(context)}?",
            style: context.titleLarge,
            textAlign: TextAlign.center,
          ),
          content: Text(
            "deleteAdsDescription".translate(context),
            style: context.labelLarge,
            textAlign: TextAlign.center,
          ),
          positiveButtonLabel: 'delete',
          negativeButtonLabel: 'cancel',
        );
      },
    );
  }
}
