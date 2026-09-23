import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:flutter/material.dart';

class VerificationIntroductionScreen extends StatelessWidget {
  const VerificationIntroductionScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const VerificationIntroductionScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (AppSession.currentUser?.isVerified == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(Routes.verification);
      });
    }
    return AppScaffold(
      body: Padding(
        padding: Constant.pagePadding.copyWith(top: kToolbarHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomImage(
              src: AppAssets.illustrators.userVerification,
              fit: BoxFit.cover,
            ),
            24.vGap,
            Text(
              'userVerification'.translate(context),
              style: context.headlineSmall.semiBold,
              textAlign: TextAlign.center,
            ),
            16.vGap,
            Text(
              'userVerificationDescription'.translate(context),
              style: context.titleMedium.withColor(context.mutedColor),
              textAlign: TextAlign.center,
            ),
            48.vGap,
            AppButton(
              variant: AppButtonVariant.filled,
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.verification);
              },
              title: 'startVerification',
            ),
          ],
        ),
      ),
    );
  }
}
