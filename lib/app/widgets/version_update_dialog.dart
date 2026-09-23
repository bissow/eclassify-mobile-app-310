import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/version.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VersionUpdateDialog {
  static void show(
    BuildContext context, {
    required Version availableVersion,
    required bool isForceUpdate,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isForceUpdate,
      builder: (context) {
        return PopScope(
          canPop: !isForceUpdate,
          child: AppDialog(
            title: Text(
              'updateAvailable'.translate(context),
              textAlign: TextAlign.center,
              style: context.titleLarge,
            ),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                Center(
                  child: Text(
                    availableVersion.toString(),
                    style: context.titleSmall.bold,
                  ),
                ),
                Text(
                  'optionalUpdateMessage'.translate(context),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            negativeButtonLabel: 'later',
            positiveButtonLabel: 'update',
            onPositiveTapped: () {
              final uri = Uri.tryParse(Constant.systemSettings.storeLink ?? '');
              if (uri == null) return;
              launchUrl(uri);
            },
          ),
        );
      },
    );
  }
}
