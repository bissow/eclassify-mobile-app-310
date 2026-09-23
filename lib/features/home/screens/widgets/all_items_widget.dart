import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/ads/native_ads_widget.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/features/home/cubits/home_items_cubit.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Item tiles are all the same shape, so a fixed extent delegate is enough.
/// This matters for more than styling: a fixed extent lets an off screen
/// [SliverGrid] report its scroll extent arithmetically, without building or
/// measuring any of its children. [ItemCard.gridDelegate] keeps that
/// property (fixed `mainAxisExtent`) while sizing the cell for the text.

class AllItemsWidget extends StatelessWidget {
  const AllItemsWidget({super.key});

  /// Builds the item grid as a run of fixed extent [SliverGrid]s separated by
  /// full width native ad slots.
  ///
  /// Splitting on the ad boundaries keeps every grid uniform, which is what
  /// makes the layout cost independent of how far the user has scrolled. The
  /// returned list holds one widget per chunk, not per item, so it stays small
  /// and the items themselves are still built lazily by each grid.
  List<Widget> _itemSlivers(
    BuildContext context, {
    required List<ItemPreview> items,
    required bool showLoader,
  }) {
    final interval = Constant.nativeAdsAfterItemNumber;
    final slivers = <Widget>[];
    // One delegate shared by every chunk: measured once, not per grid.
    final gridDelegate = ItemCard.gridDelegate(context);

    for (var start = 0; start < items.length; start += interval) {
      final end = (start + interval).clamp(0, items.length);

      slivers.add(
        SliverGrid(
          // Keyed by absolute start index so appending a page does not cause
          // existing chunks to be matched against a different slice.
          key: ValueKey('items-$start'),
          gridDelegate: gridDelegate,
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = items[start + index];
            return ItemCard.grid(key: ValueKey(item.id), item: item);
          }, childCount: end - start),
        ),
      );

      // Only slot an ad after a complete run of items, matching the previous
      // behaviour of one ad per [interval] items.
      if (end - start == interval) {
        slivers.add(
          SliverToBoxAdapter(
            key: ValueKey('ad-$start'),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: NativeAdWidget(type: TemplateType.medium),
            ),
          ),
        );
      }
    }

    if (showLoader) {
      slivers.add(
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(child: LoadingIndicator()),
          ),
        ),
      );
    }

    return slivers;
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 5,
      ),
      sliver: SliverMainAxisGroup(
        slivers: [
          BlocBuilder<HomeItemsCubit, PaginatedState<ItemPreview>>(
            builder: (context, state) {
              if (state is DataState<ItemPreview>) {
                final message = state.result.metadataAs<StringMetadata>().value;
                final isGlobalList = message.contains('No Ads found');
                if (state.result.data.isEmpty) {
                  return SliverToBoxAdapter(child: const SizedBox.shrink());
                }
                return SliverMainAxisGroup(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 10),
                      sliver: SliverToBoxAdapter(
                        child: Text(
                          'allAdvertisements'.translate(context),
                          style: context.titleMedium,
                        ),
                      ),
                    ),
                    if (isGlobalList)
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            message,
                            style: context.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              }
              return SliverToBoxAdapter(child: const SizedBox.shrink());
            },
          ),
          BlocBuilder<HomeItemsCubit, PaginatedState<ItemPreview>>(
            builder: (context, state) {
              if (state is DataState<ItemPreview>) {
                if (state.result.data.isEmpty) {
                  return SliverToBoxAdapter(
                    child: QErrorWidget.emptyData(
                      onRetry: () {
                        context.read<HomeItemsCubit>().get(reset: true);
                      },
                    ),
                  );
                }

                return SliverMainAxisGroup(
                  slivers: _itemSlivers(
                    context,
                    items: state.result.data,
                    showLoader: state is PageLoading,
                  ),
                );
              }
              if (state is Failure<ItemPreview>) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }

              return SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: .7,
                children: List.generate(
                  2,
                  (_) => const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomShimmer(height: 147, width: 250, borderRadius: 10),
                      CustomShimmer(
                        height: 15,
                        width: 90,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                      CustomShimmer(
                        height: 14,
                        width: 230,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                      CustomShimmer(
                        height: 14,
                        width: 200,
                        margin: EdgeInsetsDirectional.only(top: 8),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
