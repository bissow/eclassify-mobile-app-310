import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/category/screens/category_grid_card.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:flutter/material.dart';

/// Grid view for top-level categories.
class CategoryGridView extends StatelessWidget {
  const CategoryGridView({
    required this.categories,
    required this.isPageLoading,
    required this.onTap,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final List<Category> categories;
  final ValueNotifier<bool> isPageLoading;
  final void Function(Category category, {bool isAllCategory}) onTap;

  /// Extra scroll padding. The bottom `AppScaffold` reserved (gap, plus
  /// system inset when there is no bottom bar) is added here, so content
  /// scrolls under the bottom and only the end clears it.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isPageLoading,
      builder: (context, value, child) {
        final isLoading = value;
        return GridView.builder(
          physics: const ClampingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: padding.add(
            EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: .6,
          ),
          itemCount: categories.length + (isLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == categories.length) {
              return value
                  ? Center(child: LoadingIndicator())
                  : const SizedBox.shrink();
            }
            final category = categories[index];
            return CategoryGridCard(
              category: category,
              onTap: () => onTap(category),
            );
          },
        );
      },
    );
  }
}

class CategoryGridShimmer extends StatelessWidget {
  const CategoryGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: .65,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      children: List.generate(9, (index) => CustomShimmer(borderRadius: 12)),
    );
  }
}
