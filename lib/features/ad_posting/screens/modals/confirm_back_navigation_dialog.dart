import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class ConfirmBackNavigationDialog {
  static Future<bool?> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AppDialog(
        title: Text(
          'leaveAdPosting'.translate(context),
          style: context.titleMedium,
          textAlign: TextAlign.center,
        ),
        content: Text(
          'adPostingBackNavigationConfirmation'.translate(context),
          textAlign: TextAlign.center,
        ),
        positiveButtonLabel: 'leave'.translate(context),
        negativeButtonLabel: 'stay'.translate(context),
      ),
    );
  }
}
