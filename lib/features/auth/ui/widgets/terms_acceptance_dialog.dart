import 'package:eClassify/features/auth/ui/widgets/terms_privacy_links.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

/// A dialog that asks a new social login user to accept the Terms of Service
/// and Privacy Policy before completing registration. Tapping "Continue" IS
/// the acceptance — there's no separate checkbox to also tick.
///
/// Returns `true` if the user accepts, `false` if they cancel.
class TermsAcceptanceDialog {
  /// Convenience helper to show the dialog and await the result.
  static Future<bool?> show(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AppDialog(
          title: Text(
            "termsAndPrivacy".translate(context),
            style: context.titleLarge,
            textAlign: TextAlign.center,
          ),
          content: TermsPrivacyLinks(
            template: "pleaseAcceptTermsSocial".translate(context),
            style: context.titleSmall,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: "cancel".translate(context),
          // Positive tap IS the acceptance — no onPositiveTapped override
          // needed, AppDialog's default already pops `true`.
          positiveButtonLabel: "continue".translate(context),
        );
      },
    );
  }
}
