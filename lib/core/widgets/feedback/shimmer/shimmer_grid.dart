import 'package:flutter/material.dart';

import 'package:eClassify/core/widgets/feedback/shimmer/shimmer_grid_card.dart';

/// Grid of shimmer placeholders. Defaults to [ShimmerGridCard] cells; pass
/// [itemBuilder] for a different cell shape.
class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final IndexedWidgetBuilder? itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
    this.itemBuilder,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemBuilder: itemBuilder ?? (context, index) => const ShimmerGridCard(),
    );
  }
}
