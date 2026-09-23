import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/screens/widgets/featured_badge.dart';
import 'package:eClassify/features/item/screens/widgets/item_status_chip.dart';
import 'package:eClassify/features/item/screens/widgets/promotion_badge_strip.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/text/auto_size_text.dart';
import 'package:eClassify/features/favorite/screens/widgets/favorite_button.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/screens/widgets/featured_badge.dart';
import 'package:eClassify/features/item/screens/widgets/item_status_chip.dart';
import 'dart:math';
import 'package:eClassify/core/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

enum _ItemDisplayType { list, grid }

class ItemCard extends StatelessWidget {
  /// [aspectRatio] is only for horizontal lists, where the parent fixes the
  /// height and the card must pick its own width. Inside a grid leave it
  /// null and size the cell with [gridDelegate], which reserves the text
  /// block's real height so the price and name can't be clipped.
  const ItemCard.grid({
    required this.item,
    this.onTap,
    this.aspectRatio,
    this.onLongPress,
    super.key,
  }) : displayType = _ItemDisplayType.grid,
       shape = null;

  /// Width / height of the image area of a grid card.
  static const double gridImageAspectRatio = 1.1;

  // TODO(item-grid): interim. Measuring the text block in code duplicates
  // the card's layout; see .claude/decisions/item-grid-cell-extent.md for
  // the alternatives (self-sizing rows / aligned grid) to replace this with.
  /// Grid delegate whose cell height is `image height + text block height`,
  /// where the text block is measured from the theme's text styles and the
  /// viewer's text scale — not derived from the cell width. A ratio-based
  /// cell breaks on narrow phones and with "larger text" enabled; a fixed
  /// extent also lets an off-screen SliverGrid report its scroll extent
  /// without building children.
  static SliverGridDelegateWithFixedCrossAxisCount gridDelegate(
    BuildContext context, {
    int crossAxisCount = 2,
    double spacing = 12,
    double horizontalPadding = Constant.horizontalPadding,
  }) {
    final available =
        MediaQuery.sizeOf(context).width -
        horizontalPadding * 2 -
        spacing * (crossAxisCount - 1);
    final cellWidth = available / crossAxisCount;
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: spacing,
      crossAxisSpacing: spacing,
      mainAxisExtent:
          cellWidth / gridImageAspectRatio +
          _ItemGridCard.textBlockHeight(context),
    );
  }

  const ItemCard.list({
    required this.item,
    this.onTap,
    this.onLongPress,
    this.shape,
    super.key,
  }) : displayType = _ItemDisplayType.list,
       aspectRatio = 0;

  final ItemPreview item;
  final _ItemDisplayType displayType;
  final num? aspectRatio;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ShapeBorder? shape;

  void _defaultOnTap(BuildContext context) {
    Navigator.of(context).pushNamed(
      Routes.adDetailsScreen,
      arguments: {'item_id': item.id, 'preview': item},
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _defaultOnTap(context),
      onLongPress: onLongPress,
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        elevation: 0,
        shape:
            shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: context.colorScheme.outlineVariant),
            ),
        child: switch (displayType) {
          _ItemDisplayType.list => _ItemListTile(item: item),
          _ItemDisplayType.grid => switch (aspectRatio) {
            final ratio? => AspectRatio(
              aspectRatio: ratio.toDouble(),
              child: _ItemGridCard(item: item),
            ),
            null => _ItemGridCard(item: item),
          },
        },
      ),
    );
  }
}

class _ItemListTile extends StatelessWidget {
  const _ItemListTile({required this.item});

  final ItemPreview item;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 136,
      child: Row(
        children: [
          Stack(
            children: [
              CustomImage(
                src: item.image,
                fit: BoxFit.cover,
                size: Size.fromWidth(110),
                radius: 12,
                adaptive: true,
              ),
              if (item.hasActiveSale)
                PositionedDirectional(
                  start: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '🔥 ${item.primaryActiveSale!.discountType == 'percentage' || (item.primaryActiveSale!.discountPercentage != null && item.primaryActiveSale!.discountPercentage.toString().isNotEmpty) ? '${item.primaryActiveSale!.discountPercentage ?? item.primaryActiveSale!.discountValue}% OFF' : 'SALE'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else if (item.isFeatured)
                PositionedDirectional(start: 5, top: 5, child: FeaturedBadge())
              else if (item.isSpotlight)
                PositionedDirectional(
                  start: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '★ SPOTLIGHT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else if (item.isTopAd)
                PositionedDirectional(
                  start: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '▲ TOP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          10.hGap,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  if (item case MyItemPreview item)
                    Row(
                      spacing: 8,
                      children: [
                        if (item.isEditedByAdmin) ItemEditedChip(),
                        Expanded(
                          child: Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: ItemStatusChip(status: item.status),
                          ),
                        ),
                        if (item.type == AdItemType.videoAd)
                          CircleAvatar(
                            backgroundColor: context.colorScheme.primary
                                .withValues(alpha: .1),
                            foregroundColor: context.colorScheme.primary,
                            radius: 12,
                            child: Icon(AppIcons.playCircle, size: 16),
                          ),
                      ],
                    ),
                  if (item.activePromotions != null &&
                      item.activePromotions!.hasActivePromotions)
                    PromotionBadgeStrip(
                      promotions: item.activePromotions!,
                      compact: true,
                    ),

                  Row(
                    children: [
                      Expanded(
                        child: item.hasActiveSale
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Flexible(
                                    child: AutoSizeText(
                                      text: (item.primaryActiveSale!.formattedPromotionalPrice != null && item.primaryActiveSale!.formattedPromotionalPrice!.isNotEmpty)
                                          ? item.primaryActiveSale!.formattedPromotionalPrice!
                                          : '${item.primaryActiveSale!.promotionalPrice}',
                                      style: context.titleMedium.copyWith(
                                        color: context.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                        fontFeatures: [FontFeature.tabularFigures()],
                                      ),
                                      maxLines: 1,
                                      minimumFontSize: 13,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (item.price != null && item.price!.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        item.price!,
                                        style: context.bodySmall.copyWith(
                                          decoration: TextDecoration.lineThrough,
                                          color: context.colorScheme.outline,
                                          fontSize: 10,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              )
                            : AutoSizeText(
                                text:
                                    item.price ??
                                    'contactForPrice'.translate(context),
                                style: context.titleMedium.copyWith(
                                  color: context.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                                maxLines: 1,
                                minimumFontSize: 14,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ),
                      if (item is! MyItemPreview)
                        FavoriteButton(itemId: item.id, isLiked: item.isLiked),
                    ],
                  ),
                  AutoSizeText(
                    text: item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.titleMedium,
                  ),
                  if (item case MyItemPreview item) ...[
                    Row(
                      children: [
                        Icon(AppIcons.eye, size: 16),
                        4.hGap,
                        Text(
                          '${'views'.translate(context)}: ${item.views.compact}',
                          style: context.bodySmall,
                        ),
                        12.hGap,
                        Icon(AppIcons.heart, size: 16),
                        4.hGap,
                        Text(
                          '${'likes'.translate(context)}: ${item.likes.compact}',
                          style: context.bodySmall,
                        ),
                      ],
                    ),
                  ] else ...[
                    _iconAndText(context, AppIcons.mapPinLine, item.address),
                    _iconAndText(
                      context,
                      AppIcons.clock,
                      timeago.format(
                        item.postedAt,
                        locale: AppSession.currentLocale,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          8.hGap,
        ],
      ),
    );
  }
}

class _ItemGridCard extends StatelessWidget {
  const _ItemGridCard({required this.item});

  final ItemPreview item;

  static const _padding = 8.0;
  static const _rowSpacing = 5.0;
  static const _iconSize = 16.0;

  /// Height the text block below the image needs at the current text scale.
  /// Must mirror the rows laid out in [build]; a couple of px of slack cover
  /// font rounding so the image absorbs any remainder, never the text.
  static double textBlockHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    double line(TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: 'Ag', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      return painter.height;
    }

    final price = line(context.titleMedium);
    final name = line(context.bodyMedium);
    final meta = max(_iconSize, line(context.bodySmall));
    return _padding * 2 + _rowSpacing * 3 + price + name + meta * 2 + 2;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomImage(
                  src: item.image,
                  fit: BoxFit.cover,
                  adaptive: true,
                  radius: 12,
                ),
              ),
              if (item.hasActiveSale)
                PositionedDirectional(
                  start: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '🔥 ${item.primaryActiveSale!.discountType == 'percentage' || (item.primaryActiveSale!.discountPercentage != null && item.primaryActiveSale!.discountPercentage.toString().isNotEmpty) ? '${item.primaryActiveSale!.discountPercentage ?? item.primaryActiveSale!.discountValue}% OFF' : 'SALE'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else if (item.isFeatured)
                PositionedDirectional(
                  start: 10,
                  top: 10,
                  child: FeaturedBadge(),
                )
              else if (item.isSpotlight)
                PositionedDirectional(
                  start: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.amber, Colors.deepOrange],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '★ SPOTLIGHT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else if (item.isTopAd)
                PositionedDirectional(
                  start: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '▲ TOP',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              PositionedDirectional(
                bottom: -10,
                end: 10,
                child: FavoriteButton(itemId: item.id, isLiked: item.isLiked),
              ),
            ],
          ),
        ),
        // Natural height, never flexed: the image above takes whatever is
        // left, so a short cell shrinks the picture rather than clipping
        // the price and name. Keep in sync with [textBlockHeight].
        Padding(
          padding: const EdgeInsets.all(_padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            spacing: _rowSpacing,
            children: [
              item.hasActiveSale
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: AutoSizeText(
                            text: (item.primaryActiveSale!.formattedPromotionalPrice != null && item.primaryActiveSale!.formattedPromotionalPrice!.isNotEmpty)
                                ? item.primaryActiveSale!.formattedPromotionalPrice!
                                : '${item.primaryActiveSale!.promotionalPrice}',
                            style: context.titleMedium.copyWith(
                              color: context.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                            maxLines: 1,
                            minimumFontSize: 13,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.price != null && item.price!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              item.price!,
                              style: context.bodySmall.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: context.colorScheme.outline,
                                fontSize: 10,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    )
                  : AutoSizeText(
                      text: item.price ?? 'contactForPrice'.translate(context),
                      style: context.titleMedium.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                      maxLines: 1,
                      minimumFontSize: 14,
                      overflow: TextOverflow.ellipsis,
                    ),
              Text(
                item.name,
                style: context.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _iconAndText(context, AppIcons.mapPinLine, item.address),
              _iconAndText(
                context,
                AppIcons.clock,
                timeago.format(item.postedAt, locale: AppSession.currentLocale),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _iconAndText(BuildContext context, IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 4,
    children: [
      Icon(icon, size: _ItemGridCard._iconSize, color: context.mutedColor),
      Flexible(
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.bodySmall.withColor(context.mutedColor),
        ),
      ),
    ],
  );
}
