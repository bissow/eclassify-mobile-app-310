import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/seller/cubits/seller_items_cubit.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerLiveAdsWidget extends StatelessWidget {
  const SellerLiveAdsWidget({required this.sellerId, super.key});

  final int sellerId;

  Widget _buildItemsShimmer(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.zero,
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: .7,
      children: List.generate(4, (index) => CustomShimmer()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        BlocSelector<SellerItemsCubit, PaginatedState<ItemPreview>, int?>(
          selector: (s) => switch (s) {
            DataState(:final result) => result.total,
            _ => null,
          },
          builder: (context, total) {
            if (total == null) return const SizedBox.shrink();
            return Text(
              '$total ${'liveAds'.translate(context)}',
              style: context.titleMedium,
            );
          },
        ),
        Expanded(
          child: PaginatedGridView<SellerItemsCubit, ItemPreview, int>(
            padding: context.bodyPadding(top: 0).copyWith(left: 0, right: 0),
            parameters: sellerId,
            loadingBuilder: (context, isPageLoading) => isPageLoading
                ? LoadingIndicator()
                : _buildItemsShimmer(context),
            itemBuilder: (context, item) => ItemCard.grid(item: item),
            gridDelegate: ItemCard.gridDelegate(context, spacing: 15),
          ),
        ),
      ],
    );
  }
}
