import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/onboarding/models/onboarding_page.dart';
import 'package:flutter/material.dart';

class OnboardingPageView extends StatelessWidget {
  const OnboardingPageView({required this.controller, super.key});

  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: OnboardingPages.all.length,
      itemBuilder: (context, index) {
        final page = OnboardingPages.all[index];
        return CustomImage(src: page.image, fit: BoxFit.contain);
      },
    );
  }
}
