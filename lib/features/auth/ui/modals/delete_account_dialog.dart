import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class DeleteAccountDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          icon: CustomImage(src: AppAssets.illustrators.delete),
          title: Text(
            "deleteProfileMessageTitle".translate(context),
            style: context.titleLarge,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _bulletPoint(
                context,
                "deleteAccountAdsNotice".translate(context),
              ),
              _bulletPoint(
                context,
                "deleteAccountRecoveryWarning".translate(context),
              ),
              _bulletPoint(
                context,
                "deleteAccountSubscriptionsWarning".translate(context),
              ),
              _bulletPoint(
                context,
                "deleteAccountPreferencesWarning".translate(context),
              ),
            ],
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          positiveButtonLabel: 'confirm'.translate(context),
        );
      },
    );
  }
}

Widget _bulletPoint(BuildContext context, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: 5,
    children: [
      Text('• ', style: context.bodyLarge.bold),
      Expanded(child: Text(text, style: context.bodyMedium)),
    ],
  );
}
