import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

/// Shown when account deletion hits Firebase's `requires-recent-login`.
/// Offers logging out (so the user can sign back in and retry) instead of
/// an in-app reauthentication prompt.
class FreshLoginRequiredDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'freshLoginRequiredTitle'.translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            'freshLoginRequiredMessage'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'stayLoggedIn'.translate(context),
          positiveButtonLabel: 'logout'.translate(context),
        );
      },
    );
  }
}
