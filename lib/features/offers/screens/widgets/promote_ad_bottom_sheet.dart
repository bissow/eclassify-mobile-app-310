import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/offers/cubits/seller_ad_promote_cubit.dart';
import 'package:eClassify/features/offers/models/ad_promotion_options_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PromoteAdBottomSheet extends StatefulWidget {
  const PromoteAdBottomSheet({required this.itemId, super.key});

  final int itemId;

  static Future<void> show(BuildContext context, {required int itemId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => SellerAdPromoteCubit()..fetchPromotionOptions(itemId),
        child: PromoteAdBottomSheet(itemId: itemId),
      ),
    );
  }

  @override
  State<PromoteAdBottomSheet> createState() => _PromoteAdBottomSheetState();
}

class _PromoteAdBottomSheetState extends State<PromoteAdBottomSheet> {
  String _selectedType = 'daily_bump_up';
  int _durationDays = 7;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SellerAdPromoteCubit, SellerAdPromoteState>(
      listener: (context, state) {
        if (state is SellerAdPromoteActionSuccess) {
          HelperUtils.showSnackBarMessage(context, state.message);
          Navigator.of(context).pop();
        } else if (state is SellerAdPromoteFailure) {
          HelperUtils.showSnackBarMessage(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        final isCurrentlyActiveSelected = (state is SellerAdPromoteOptionsSuccess) &&
            ((_selectedType == 'daily_bump_up' && state.options.isDailyBumpActive) ||
                (_selectedType == 'top_ad' && state.options.isTopAdActive) ||
                (_selectedType == 'spotlight' && state.options.isSpotlightActive));

        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Row(
                  children: [
                    Icon(AppIcons.sparkleFill, color: context.colorScheme.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'promoteYourAd'.translate(context),
                      style: context.titleLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'boostYourAdSubtitle'.translate(context),
                  style: context.bodyMedium.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 20),

                if (state is SellerAdPromoteLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: LoadingIndicator()))
                else if (state is SellerAdPromoteOptionsSuccess) ...[
                  if (state.options.requiresVerification)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.verified_user_outlined, color: Colors.amber, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.options.verificationStatus == 'pending' || state.options.verificationStatus == 'resubmitted'
                                      ? 'verificationUnderReviewTitle'.translate(context)
                                      : 'verificationRequiredTitle'.translate(context),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.options.message ??
                                (state.options.verificationStatus == 'pending' || state.options.verificationStatus == 'resubmitted'
                                    ? 'verificationUnderReviewNotice'.translate(context)
                                    : 'verificationRequiredDesc'.translate(context)),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AppButton(
                            variant: AppButtonVariant.filled,
                            size: AppButtonSize.compact,
                            title: (state.options.verificationStatus == 'pending' || state.options.verificationStatus == 'resubmitted')
                                ? 'checkVerificationStatus'.translate(context)
                                : 'verifyNow'.translate(context),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(Routes.verification);
                            },
                          ),
                        ],
                      ),
                    )
                  else if (state.options.requiresPackage)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.card_membership_outlined, color: context.colorScheme.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'packageRequiredTitle'.translate(context),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            state.options.message ?? 'packageRequiredDesc'.translate(context),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          AppButton(
                            variant: AppButtonVariant.filled,
                            size: AppButtonSize.compact,
                            title: 'subscribePackage'.translate(context),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed(Routes.subscriptionPackageScreen);
                            },
                          ),
                        ],
                      ),
                    ),
                  _buildOptions(context, state.options),
                  if (isCurrentlyActiveSelected) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: context.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'boostActiveNotice'.translate(context),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ] else
                  const SizedBox.shrink(),

                const SizedBox(height: 24),
                AppButton(
                  variant: AppButtonVariant.filled,
                  onPressed: (state is! SellerAdPromoteOptionsSuccess ||
                          state.options.requiresVerification ||
                          state.options.requiresPackage)
                      ? null
                      : () {
                          context.read<SellerAdPromoteCubit>().promoteAd(
                            itemId: widget.itemId,
                            promotionType: _selectedType,
                            durationDays: _durationDays,
                          );
                        },
                  title: isCurrentlyActiveSelected
                      ? 'extendOrReplaceBoost'.translate(context)
                      : 'boostNow'.translate(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptions(BuildContext context, AdPromotionOptionsModel options) {
    final list = [
      (
        id: 'daily_bump_up',
        title: 'dailyBumpUp'.translate(context),
        desc: 'dailyBumpDesc'.translate(context),
        icon: AppIcons.trendUp,
        available: options.canBump,
        remaining: options.bumpRemaining,
        isActive: options.isDailyBumpActive,
      ),
      (
        id: 'top_ad',
        title: 'topAd'.translate(context),
        desc: 'topAdDesc'.translate(context),
        icon: AppIcons.starFill,
        available: options.canTopAd,
        remaining: options.topAdRemaining,
        isActive: options.isTopAdActive,
      ),
      (
        id: 'spotlight',
        title: 'spotlightAd'.translate(context),
        desc: 'spotlightDesc'.translate(context),
        icon: AppIcons.sparkleFill,
        available: options.canSpotlight,
        remaining: options.spotlightRemaining,
        isActive: options.isSpotlightActive,
      ),
    ];

    return Column(
      children: list.map((item) {
        final isSelected = _selectedType == item.id;
        final isAvailable = item.available;

        return GestureDetector(
          onTap: () {
            if (isAvailable) {
              setState(() {
                _selectedType = item.id;
              });
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary.withValues(alpha: 0.08)
                  : context.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? context.colorScheme.primary : context.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    size: 20,
                    color: isSelected ? Colors.white : context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (item.isActive) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'boostCurrentlyActive'.translate(context),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            isAvailable
                                ? '${item.remaining} ${'creditsLeft'.translate(context)}'
                                : 'quotaExhausted'.translate(context),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isAvailable ? context.colorScheme.primary : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.desc,
                        style: TextStyle(
                          fontSize: 11,
                          color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
