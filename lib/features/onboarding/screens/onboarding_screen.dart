import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/inputs/skip_button_widget.dart';
import 'package:eClassify/features/onboarding/models/onboarding_page.dart';
import 'package:eClassify/features/onboarding/screens/widgets/language_selector.dart';
import 'package:eClassify/features/onboarding/screens/widgets/onboarding_page_view.dart';
import 'package:eClassify/features/onboarding/screens/widgets/page_indicator.dart';
import 'package:eClassify/features/onboarding/storage/onboarding_storage.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const OnboardingScreen(),
    );
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        leading: LanguageSelector(),
        leadingWidth: 100,
        actions: [
          SkipButtonWidget(
            onTap: () {
              OnboardingStorage.completeOnboarding();
              Navigator.pushReplacementNamed(context, Routes.auth);
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight * .65,
                ),
                child: Padding(
                  padding: Constant.pagePadding.copyWith(
                    top: Constant.verticalPadding,
                  ),
                  child: OnboardingPageView(controller: _controller),
                ),
              ),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.secondary,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: context.bodyPadding(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: ListenableBuilder(
                            listenable: _controller,
                            builder: (context, child) {
                              int index;
                              if (_controller.hasClients) {
                                index = _controller.page?.round() ?? 0;
                              } else {
                                index = 0;
                              }
                              final page = OnboardingPages.all[index];
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    page.titleKey.translate(context),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: context.headlineSmall.copyWith(
                                      color: context.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      page.descriptionKey.translate(context),
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      style: context.titleMedium.withColor(
                                        context.mutedColor,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.zero,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PageIndicator(
                                controller: _controller,
                                count: OnboardingPages.all.length,
                              ),
                              FloatingActionButton(
                                backgroundColor: context.colorScheme.primary,
                                foregroundColor: context.colorScheme.surface,
                                shape: CircleBorder(),
                                elevation: 0,
                                onPressed: () {
                                  final isLast =
                                      _controller.page?.round() ==
                                      OnboardingPages.all.length - 1;
                                  if (isLast) {
                                    OnboardingStorage.completeOnboarding();

                                    Navigator.pushReplacementNamed(
                                      context,
                                      Routes.auth,
                                    );
                                  } else {
                                    _controller.nextPage(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.decelerate,
                                    );
                                  }
                                },
                                child: Icon(AppIcons.arrowRight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
