import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:flutter/material.dart';

class ChatDeleteConfirmationDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'deleteChatTitle'.translate(context),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'deleteChatContent'.translate(context),
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'cancel',
          positiveButtonLabel: 'confirm',
        );
      },
    );
  }
}
