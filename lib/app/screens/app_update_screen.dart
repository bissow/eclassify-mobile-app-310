import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/version.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/core/utils/version_utility.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const AppUpdateScreen(),
    );
  }

  Widget _versionRow(BuildContext context, String labelKey, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(labelKey.translate(context), style: context.bodyMedium),
        Text(value, style: context.bodyMedium.bold),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = Constant.systemSettings.version;

    return PopScope(
      canPop: false,
      child: AppScaffold(
        body: Padding(
          padding: context.bodyPadding(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [
              CustomImage(src: AppAssets.illustrators.appUpdate),
              Text(
                'updateAvailable'.translate(context),
                style: context.titleLarge.bold,
              ),
              Text(
                'mandatoryUpdateMessage'.translate(context),
                style: context.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              FutureBuilder<Version>(
                future: VersionUtility.currentPackageVersion,
                builder: (context, snapshot) {
                  final current = snapshot.data;
                  if (snapshot.hasError) {
                    Log.error(snapshot.error.toString(), snapshot.error, null);
                  }
                  return Column(
                    spacing: 4,
                    children: [
                      if (current != null)
                        _versionRow(
                          context,
                          'currentVersion',
                          current.toString(),
                        ),
                      _versionRow(context, 'latestVersion', latest.toString()),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              AppButton(
                variant: AppButtonVariant.filled,
                onPressed: () {
                  final uri = Uri.tryParse(
                    Constant.systemSettings.storeLink ?? '',
                  );
                  if (uri == null) return;
                  launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                title: 'update',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
