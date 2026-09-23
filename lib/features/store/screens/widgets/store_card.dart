import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:flutter/material.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({
    required this.store,
    this.onTap,
    super.key,
  });

  final StoreModel store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final locationText = [
      if (store.areaName != null && store.areaName!.isNotEmpty) store.areaName,
      if (store.city != null && store.city!.isNotEmpty) store.city,
      if (store.state != null && store.state!.isNotEmpty) store.state,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.pushNamed(
              context,
              Routes.storeDetails,
              arguments: {'slug': store.slug, 'id': store.id},
            );
          },
      child: Container(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner & Logo stack
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover Banner
                SizedBox(
                  height: 100,
                  width: double.infinity,
                  child: store.banner != null && store.banner!.isNotEmpty
                      ? CustomImage(
                          src: store.banner!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                context.colorScheme.primary.withValues(alpha: 0.7),
                                context.colorScheme.primary.withValues(alpha: 0.3),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              AppIcons.storefront,
                              size: 36,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                ),
                // Distance badge on top right of banner
                if (store.distance != null && store.distance!.formatted.isNotEmpty)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            AppIcons.mapPinFill,
                            size: 12,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            store.distance!.formatted,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Circular Store Logo
                Positioned(
                  left: 14,
                  bottom: -24,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colorScheme.surface,
                      border: Border.all(
                        color: context.colorScheme.surface,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: store.logo != null && store.logo!.isNotEmpty
                          ? CustomImage(
                              src: store.logo!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: context.colorScheme.primary.withValues(alpha: 0.15),
                              child: Icon(
                                AppIcons.storefront,
                                size: 24,
                                color: context.colorScheme.primary,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            // Body info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Name & Verified
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          store.name,
                          style: context.bodyLarge.bold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (store.isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          AppIcons.sealCheckFill,
                          color: context.colorScheme.primary,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Location Address text
                  Row(
                    children: [
                      Icon(
                        AppIcons.mapPin,
                        size: 14,
                        color: context.mutedColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          locationText.isNotEmpty
                              ? locationText
                              : (store.address ?? 'location'.translate(context)),
                          style: context.bodySmall.withColor(context.mutedColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (store.description != null && store.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      store.description!,
                      style: context.bodySmall.withColor(context.mutedColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  // Rating & Active Items
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating
                      Row(
                        children: [
                          const Icon(
                            AppIcons.starFill,
                            color: Colors.amber,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (store.stats?.averageRating ?? 0.0).toStringAsFixed(1),
                            style: context.bodySmall.semiBold,
                          ),
                          if ((store.stats?.totalReviews ?? 0) > 0)
                            Text(
                              ' (${store.stats!.totalReviews})',
                              style: context.bodySmall.withColor(context.mutedColor),
                            ),
                        ],
                      ),
                      // Products count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${store.stats?.activeItemsCount ?? 0} ${'items'.translate(context)}',
                          style: context.bodySmall.semiBold.copyWith(
                            color: context.colorScheme.primary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
