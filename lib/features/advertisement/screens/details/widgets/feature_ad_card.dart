import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/features/advertisement/cubits/create_featured_ad_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/fetch_item_cubit.dart';
import 'package:eClassify/features/subscription/cubits/user_package_limit_cubit.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/screens/widgets/no_package_available_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FeatureAdCard extends StatelessWidget {
  const FeatureAdCard({required this.itemId, super.key});

  final int itemId;

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
          padding: EdgeInsets.all(16),
          child: Row(
            spacing: 16,
            children: [
              CustomImage(
                src: AppAssets.illustrators.createAdd,
                size: Size(64, 76),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Text(
                      'featureAdDescription'.translate(context),
                      style: context.titleMedium,
                    ),
                    AppButton(
                      variant: AppButtonVariant.filled,
                      size: AppButtonSize.small,
                      title: 'createFeaturedAd',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
