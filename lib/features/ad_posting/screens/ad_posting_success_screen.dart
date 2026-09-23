import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/lottie_utility.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class AdPostingSuccessScreen extends StatefulWidget {
  const AdPostingSuccessScreen({
    required this.item,
    required this.isEdited,
    this.isUploadInProgress = false,
    super.key,
  });

  final MyItem item;
  final bool isEdited;
  final bool isUploadInProgress;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map<String, dynamic>;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => AdPostingSuccessScreen(
        item: args['item'] as MyItem,
        isEdited: args['is_edited'] as bool? ?? false,
        isUploadInProgress: args['is_upload_in_progress'] as bool? ?? false,
      ),
    );
  }

  @override
  State<AdPostingSuccessScreen> createState() => _AdPostingSuccessScreenState();
}

class _AdPostingSuccessScreenState extends State<AdPostingSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;
  late final AnimationController _buttonController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this)
      ..addListener(() {
        if (_lottieController.value > 0.5 && _buttonController.value == 0) {
          _buttonController.forward();
        }
      });
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _buttonController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AppScaffold(
        body: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Lottie.asset(
                LottieAssets.success,
                controller: _lottieController,
                onLoaded: (composition) {
                  _lottieController.duration = composition.duration;
                  _lottieController.forward();
                },
                delegates: LottieUtility.getSuccessDelegates(
                  color: context.colorScheme.primary,
                ),
              ),
              32.vGap,
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!widget.isEdited)
                        Text(
                          'congratulations'.translate(context),
                          textAlign: TextAlign.center,
                          style: context.headlineSmall.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      8.vGap,
                      Text(
                        (widget.isEdited
                                ? 'updatedSuccess'
                                : 'submittedSuccess')
                            .translate(context),
                        textAlign: TextAlign.center,
                        style: context.titleMedium,
                      ),
                      if (widget.isUploadInProgress) ...[
                        16.vGap,
                        Text(
                          'videoUploadBackground'.translate(context),
                          textAlign: TextAlign.center,
                          style: context.bodyMedium.copyWith(
                            color: context.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                      32.vGap,
                      AppButton(
                        variant: AppButtonVariant.filled,
                        onPressed: () {
                          if (widget.isEdited) {
                            Navigator.of(context).popUntilWithResult(
                              (route) =>
                                  route.settings.name == Routes.adDetailsScreen,
                              true,
                            );
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.adDetailsScreen,
                              (route) => route.isFirst,
                              arguments: {
                                'item_id': widget.item.id,
                                'is_my_item': true,
                              },
                            );
                          }
                        },
                        title: 'previewAd',
                      ),
                      24.vGap,
                      AppButton(
                        variant: AppButtonVariant.outlined,
                        width: AppButtonWidth.content,
                        foregroundColor: context.colorScheme.primary,
                        onPressed: () {
                          context.read<BottomNavCubit>().changeTab(
                            BottomTab.home,
                          );
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        child: Text('backToHome'.translate(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
