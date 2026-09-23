import 'package:eClassify/core/constants/app_assets.dart';

final class OnboardingPage {
  const OnboardingPage({
    required this.image,
    required this.titleKey,
    required this.descriptionKey,
  });

  final String image;
  final String titleKey;
  final String descriptionKey;
}

abstract final class OnboardingPages {
  static final List<OnboardingPage> all = [
    OnboardingPage(
      image: AppAssets.illustrators.onboardingA,
      titleKey: 'onboarding_1_title',
      descriptionKey: 'onboarding_1_des',
    ),
    OnboardingPage(
      image: AppAssets.illustrators.onboardingB,
      titleKey: 'onboarding_2_title',
      descriptionKey: 'onboarding_2_des',
    ),
    OnboardingPage(
      image: AppAssets.illustrators.onboardingC,
      titleKey: 'onboarding_3_title',
      descriptionKey: 'onboarding_3_des',
    ),
  ];
}
