import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/features/category/cubits/main_category_cubit.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllCategoryWidget extends StatelessWidget {
  const AllCategoryWidget({super.key});

  static const _maxItemsToDisplay = 5;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: BlocBuilder<MainCategoryCubit, MainCategoryState>(
        builder: (context, state) {
          if (state is MainCategoryLoading) {
            return _CategoryList(
              itemCount: 5,
              itemBuilder: (_, _) =>
                  CustomShimmer(height: 30, width: 100, borderRadius: 24),
            );
          }

          if (state is MainCategorySuccess) {
            final categories = state.categories;
            final length = categories.length;
            final showMoreButton = length > _maxItemsToDisplay;
            final itemsToShow = showMoreButton
                ? _maxItemsToDisplay + 1
                : length;

            return _CategoryList(
              itemCount: itemsToShow,
              itemBuilder: (context, index) {
                if (showMoreButton && index == _maxItemsToDisplay) {
                  return _CategoryChip(
                    title: 'viewMore'.translate(context),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.categoryBrowsing);
                    },
                  );
                }
                final category = categories[index];
                return _CategoryChip(
                  title: category.name.localized,
                  onPressed: () {
                    if (category.hasSubCategories) {
                      Navigator.of(
                        context,
                      ).pushNamed(Routes.categoryBrowsing, arguments: category);
                    } else {
                      Navigator.of(context).pushNamed(
                        Routes.itemsList,
                        arguments: CategoryMetaData(category: category),
                      );
                    }
                  },
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 40),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
        separatorBuilder: (context, index) => 10.hGap,
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.title, required this.onPressed});

  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onPressed,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: WidgetStatePropertyAll(context.colorScheme.secondary),
      side: BorderSide.none,
      label: Text(title, style: context.bodySmall),
    );
  }
}
