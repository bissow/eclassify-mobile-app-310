import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class LogoutDialog {
  static Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          icon: CustomImage(src: AppAssets.illustrators.logout),
          title: Text(
            "confirmLogoutTitle".translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            "confirmLogOutDescription".translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          positiveButtonLabel: 'confirm'.translate(context),
        );
      },
    );
  }
}
