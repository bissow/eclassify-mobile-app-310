import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class BlockUserDialog {
  static Future<bool?> show(
    BuildContext context, {
    required UserPreview user,
    required bool isUserBlocked,
  }) async {
    final contentLabel = isUserBlocked
        ? "${"unblock".translate(context)}\t${user.name}\t${"toSendMessage".translate(context)}"
              .translate(context)
        : "${"block".translate(context)}\t${user.name}?".translate(context);
    final buttonLabel = isUserBlocked
        ? "unblock".translate(context)
        : "block".translate(context);

    return await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Text(
                contentLabel,
                style: context.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (!isUserBlocked)
                Text(
                  'blockWarning'.translate(context),
                  style: context.labelLarge,
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            AppButton(
              variant: AppButtonVariant.filled,
              size: AppButtonSize.small,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(buttonLabel),
            ),
          ],
        );
      },
    );
  }
}
