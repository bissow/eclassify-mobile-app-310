import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

/// Shown when email/password sign-in succeeds against Firebase but the
/// account's email was never verified. Offers resending the verification
/// email rather than leaving the user stuck with no way forward.
class EmailNotVerifiedDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'emailNotVerifiedTitle'.translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            'emailNotVerifiedMessage'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          positiveButtonLabel: 'sendVerificationEmail'.translate(context),
        );
      },
    );
  }
}
