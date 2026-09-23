import 'package:eClassify/features/ad_posting/cubits/ad_posting_cubit.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdTypeSelectionStep extends StatelessWidget {
  const AdTypeSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdPostingCubit, AdPostingState>(
      builder: (context, state) {
        final currentType = state.adPostingData.adType;
        final cubit = context.read<AdPostingCubit>();

        return Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 16,
            children: [
              _AdTypeCard(
                icon: AppIcons.shoppingBagOpen,
                title: 'regularAdsTitle'.translate(context),
                subtitle: 'regularAdsSubtitle'.translate(context),
                isSelected: currentType == AdItemType.regularAd,
                onTap: () {
                  cubit
                    ..updateData(
                      (data) => data.copyWith(itemType: AdItemType.regularAd),
                    )
                    ..nextStep();
                },
              ),
              _AdTypeCard(
                icon: AppIcons.playCircle,
                title: 'videoAdsTitle'.translate(context),
                subtitle: 'videoAdsSubtitle'.translate(context),
                isSelected: currentType == AdItemType.videoAd,
                onTap: () {
                  cubit
                    ..updateData(
                      (data) => data.copyWith(itemType: AdItemType.videoAd),
                    )
                    ..nextStep();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdTypeCard extends StatelessWidget {
  const _AdTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isSelected,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? context.colorScheme.primary : Colors.transparent,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CircleAvatar(
                backgroundColor: context.colorScheme.primary.withValues(
                  alpha: .1,
                ),
                foregroundColor: context.colorScheme.primary,
                radius: 30,
                child: Icon(icon, size: 32),
              ),
              12.vGap,
              Text(
                title,
                style: context.labelLarge,
                textAlign: TextAlign.center,
              ),
              4.vGap,
              Text(
                subtitle,
                style: context.labelMedium.withColor(context.mutedColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
