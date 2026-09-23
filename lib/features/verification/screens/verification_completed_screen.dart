import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/lottie_utility.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VerificationCompletedScreen extends StatelessWidget {
  const VerificationCompletedScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const VerificationCompletedScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Padding(
        padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LottieBuilder.asset(
              LottieAssets.success,
              delegates: LottieUtility.getSuccessDelegates(
                color: context.colorScheme.primary,
              ),
            ),
            24.vGap,
            Text(
              'verificationCompleted'.translate(context),
              style: context.headlineSmall.withColor(
                context.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            20.vGap,
            Text(
              'userVerificationReviewDescription'.translate(context),
              style: context.bodyLarge.withColor(context.mutedColor),
              textAlign: TextAlign.center,
            ),
            20.vGap,
            AppButton(
              variant: AppButtonVariant.filled,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              title: 'backToProfile',
            ),
          ],
        ),
      ),
    );
  }
}
