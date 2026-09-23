import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/features/advertisement/cubits/create_featured_ad_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/fetch_item_cubit.dart';
import 'package:eClassify/features/subscription/cubits/user_package_limit_cubit.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/screens/widgets/no_package_available_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:eClassify/features/offers/screens/widgets/promote_ad_bottom_sheet.dart';
import 'package:eClassify/features/offers/screens/widgets/add_to_promotion_bottom_sheet.dart';

class FeatureAdCard extends StatelessWidget {
  const FeatureAdCard({required this.itemId, this.price = 0.0, super.key});

  final int itemId;
  final double price;

  Future<bool?> _showConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'createFeaturedAdTitle'.translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'createFeatureAdDescription'.translate(context),
            textAlign: TextAlign.center,
            style: context.bodyMedium,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          onNegativeTapped: () => Navigator.of(context).pop(false),
          positiveButtonLabel: 'yes'.translate(context),
          onPositiveTapped: () => Navigator.of(context).pop(true),
        );
      },
    );
  }

  void _showVerificationRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'verificationRequiredTitle'.translate(context),
            style: context.titleMedium,
            textAlign: TextAlign.center,
          ),
          content: Text(
            'verificationRequiredDesc'.translate(context),
            textAlign: TextAlign.center,
            style: context.bodyMedium,
          ),
          negativeButtonLabel: 'cancel'.translate(context),
          onNegativeTapped: () => Navigator.of(context).pop(),
          positiveButtonLabel: 'verifyNow'.translate(context),
          onPositiveTapped: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(Routes.verification);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateFeaturedAdCubit, CreateFeaturedAdState>(
          listener: (context, state) {
            if (state is CreateFeaturedAdSuccess) {
              HelperUtils.showSnackBarMessage(context, state.responseMessage);
              context.read<FetchItemCubit>().fetchItem(
                itemId: itemId,
                isMyAd: true,
              );
            }
            if (state is CreateFeaturedAdFailure) {
              HelperUtils.showSnackBarMessage(context, state.error);
            }
          },
        ),
        BlocListener<UserPackageLimitCubit, UserPackageLimitState>(
          listener: (context, state) async {
            if (state is UserPackageLimitFailure) {
              NoPackageAvailableDialog.show(
                context,
                type: SubscriptionPackageType.featuredAds,
              );
            }
            if (state is UserPackageLimitSuccess) {
              final shouldFeature =
                  await _showConfirmationDialog(context) ?? false;
              if (shouldFeature) {
                context.read<CreateFeaturedAdCubit>().createFeaturedAds(
                  itemId: itemId,
                );
              }
            }
          },
        ),
      ],
      child: Card.filled(
        margin: EdgeInsets.symmetric(
          horizontal: Constant.horizontalPadding,
          vertical: 8,
        ),
        color: context.colorScheme.primary.withValues(alpha: .1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 16,
                children: [
                  CustomImage(
                    src: AppAssets.illustrators.createAdd,
                    size: const Size(54, 64),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'boostYourAd'.translate(context),
                          style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'featureAdDescription'.translate(context),
                          style: context.bodySmall.copyWith(color: context.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  AppButton(
                    variant: AppButtonVariant.filled,
                    size: AppButtonSize.small,
                    title: 'promoteAd'.translate(context),
                    onPressed: () {
                      final isVerified = AppSession.currentUser?.isVerified ?? false;
                      if (!isVerified) {
                        _showVerificationRequiredDialog(context);
                        return;
                      }
                      PromoteAdBottomSheet.show(context, itemId: itemId);
                    },
                  ),
                  AppButton(
                    variant: AppButtonVariant.outlined,
                    size: AppButtonSize.small,
                    title: 'joinSale'.translate(context),
                    onPressed: () {
                      final isVerified = AppSession.currentUser?.isVerified ?? false;
                      if (!isVerified) {
                        _showVerificationRequiredDialog(context);
                        return;
                      }
                      AddToPromotionBottomSheet.show(
                        context,
                        itemId: itemId,
                        originalPrice: price,
                      );
                    },
                  ),
                  AppButton(
                    variant: AppButtonVariant.outlined,
                    size: AppButtonSize.small,
                    title: 'createFeaturedAd'.translate(context),
                    onPressed: () {
                      context
                          .read<UserPackageLimitCubit>()
                          .fetchUserPackageLimit(
                            packageType: SubscriptionPackageType.featuredAds,
                          );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
