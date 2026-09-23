import 'package:eClassify/features/advertisement/cubits/related_items_cubit.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RelatedItemsList extends StatefulWidget {
  const RelatedItemsList({
    required this.categoryId,
    required this.itemId,
    super.key,
  });

  final int? categoryId;
  final int? itemId;

  @override
  State<RelatedItemsList> createState() => _RelatedItemsListState();
}

class _RelatedItemsListState extends State<RelatedItemsList> {
  @override
  void didUpdateWidget(covariant RelatedItemsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId) {
      context.read<RelatedItemsCubit>().fetchRelatedItems(
        categoryId: widget.categoryId!,
        location: AppSession.currentLocation,
        excludedItemId: widget.itemId!,
      );
    }
  }

  Widget _shimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          CustomShimmer(width: 150, height: 20, borderRadius: 16),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              children: List.generate(
                5,
                (_) => AspectRatio(
                  aspectRatio: .7,
                  child: CustomShimmer(
                    borderRadius: 16,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RelatedItemsCubit, RelatedItemsState>(
      builder: (context, state) {
        if (state is RelatedItemsInitial || state is RelatedItemsLoading) {
          return _shimmer();
        }
        if (state is RelatedItemsSuccess) {
          if (state.items.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constant.horizontalPadding,
                ),
                child: Text(
                  'relatedAds'.translate(context),
                  style: context.titleMedium,
                ),
              ),
              SizedBox(
                height: HelperUtils.lerpHeight(
                  screenHeight: context.screenHeight,
                  minHeight: 245,
                  maxHeight: 285,
                  minScreen: 600,
                  maxScreen: 850,
                ),
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: Constant.horizontalPadding,
                  ),
                  itemBuilder: (context, index) =>
                      ItemCard.grid(item: state.items[index], aspectRatio: .7),
                  separatorBuilder: (_, _) => 10.hGap,
                  itemCount: state.items.length,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
