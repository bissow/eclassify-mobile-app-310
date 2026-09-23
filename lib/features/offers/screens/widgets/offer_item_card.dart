import 'dart:async';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/offers/models/promotion_item_model.dart';
import 'package:flutter/material.dart';

class OfferItemCard extends StatefulWidget {
  const OfferItemCard({
    required this.item,
    this.onTap,
    super.key,
  });

  final PromotionItemModel item;
  final VoidCallback? onTap;

  @override
  State<OfferItemCard> createState() => _OfferItemCardState();
}

class _OfferItemCardState extends State<OfferItemCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  void _initTimer() {
    if (widget.item.validUntil != null) {
      _remaining = widget.item.validUntil!.difference(DateTime.now());
      if (!_remaining.isNegative) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          final diff = widget.item.validUntil!.difference(DateTime.now());
          if (diff.isNegative) {
            timer.cancel();
            setState(() {
              _remaining = Duration.zero;
            });
          } else {
            setState(() {
              _remaining = diff;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDiscountPercentage = item.discountType == 'percentage';

    return GestureDetector(
      onTap: widget.onTap ?? () {
        Navigator.pushNamed(
          context,
          Routes.adDetailsScreen,
          arguments: {
            'item_id': item.itemId,
            'slug': item.itemSlug,
          },
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: context.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        color: context.colorScheme.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: CustomImage(
                    src: item.itemImage ?? '',
                    fit: BoxFit.cover,
                  ),
                ),

                // Discount Badge
                if (item.discountValue > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(AppIcons.lightningFill, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            isDiscountPercentage ? '-${item.discountValue.toInt()}% OFF' : '-${item.formattedOriginalPrice}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Countdown Strip
                if (!_remaining.isNegative && _remaining > Duration.zero)
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(AppIcons.clock, size: 12, color: Colors.amberAccent),
                              const SizedBox(width: 4),
                              Text(
                                'Ends in:',
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                              ),
                            ],
                          ),
                          Text(
                            _formatDuration(_remaining),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Item Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.itemName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Prices
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Flexible(
                        child: Text(
                          item.formattedPromotionalPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.colorScheme.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      if (item.originalPrice > item.promotionalPrice) ...[
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            item.formattedOriginalPrice,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Stock Progress Bar
                  if (item.stockQuantity > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${item.claimedStock} sold',
                          style: TextStyle(fontSize: 10, color: context.colorScheme.onSurface.withValues(alpha: 0.6)),
                        ),
                        Text(
                          '${item.remainingStockQuantity} left',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: item.remainingStockQuantity <= 3 ? Colors.redAccent : context.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: item.stockPercentage,
                        minHeight: 5,
                        backgroundColor: context.colorScheme.outlineVariant.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          item.remainingStockQuantity <= 3 ? Colors.redAccent : context.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
