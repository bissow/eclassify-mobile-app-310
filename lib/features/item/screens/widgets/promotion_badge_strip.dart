import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/features/item/models/active_promotions_summary.dart';
import 'package:flutter/material.dart';

class PromotionBadgeStrip extends StatelessWidget {
  const PromotionBadgeStrip({
    required this.promotions,
    this.compact = false,
    super.key,
  });

  final ActivePromotionsSummary promotions;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!promotions.hasActivePromotions) {
      return const SizedBox.shrink();
    }

    final badges = <Widget>[];

    if (promotions.isDailyBumped) {
      badges.add(
        _BadgeChip(
          icon: AppIcons.arrowsClockwise,
          label: 'dailyBump'.translate(context),
          bgColor: Colors.cyan.withValues(alpha: 0.15),
          textColor: Colors.cyan.shade800,
          borderColor: Colors.cyan.withValues(alpha: 0.35),
          compact: compact,
        ),
      );
    }

    if (promotions.isTopAd) {
      badges.add(
        _BadgeChip(
          icon: AppIcons.fireFill,
          label: 'topAd'.translate(context),
          bgColor: Colors.amber.withValues(alpha: 0.15),
          textColor: Colors.amber.shade800,
          borderColor: Colors.amber.withValues(alpha: 0.35),
          compact: compact,
        ),
      );
    }

    if (promotions.isSpotlight) {
      badges.add(
        _BadgeChip(
          icon: AppIcons.sparkleFill,
          label: 'spotlight'.translate(context),
          bgColor: Colors.purple.withValues(alpha: 0.15),
          textColor: Colors.purple.shade700,
          borderColor: Colors.purple.withValues(alpha: 0.35),
          compact: compact,
        ),
      );
    }

    for (final sale in promotions.sales) {
      final discountStr = sale.discountPercentage != null && sale.discountPercentage.toString().isNotEmpty
          ? ' -${sale.discountPercentage}%'
          : '';
      final title = (sale.campaignTitle != null && sale.campaignTitle!.isNotEmpty)
          ? sale.campaignTitle!
          : (sale.promotionTitle ?? 'activeSale'.translate(context));

      badges.add(
        _BadgeChip(
          icon: AppIcons.lightningFill,
          label: '$title$discountStr',
          bgColor: context.colorScheme.error.withValues(alpha: 0.12),
          textColor: context.colorScheme.error,
          borderColor: context.colorScheme.error.withValues(alpha: 0.3),
          compact: compact,
        ),
      );
    }


    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: badges,
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : 6,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 10 : 12, color: textColor),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
