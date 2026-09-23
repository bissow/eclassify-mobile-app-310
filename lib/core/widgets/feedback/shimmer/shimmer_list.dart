import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/widgets/feedback/shimmer/shimmer_list_tile.dart';
import 'package:flutter/material.dart';

/// Scrollable list of shimmer placeholders. Defaults to [ShimmerListTile]
/// rows; pass [itemBuilder] for a different row shape (e.g. a chat bubble).
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final Widget? separator;
  final Axis scrollDirection;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ShimmerList({
    super.key,
    this.itemCount = 8,
    this.itemBuilder,
    this.separator,
    this.scrollDirection = Axis.vertical,
    this.padding,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: scrollDirection,
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      separatorBuilder: (context, index) =>
          separator ?? (scrollDirection == Axis.vertical ? 8.vGap : 8.hGap),
      itemBuilder: itemBuilder ?? (context, index) => const ShimmerListTile(),
    );
  }
}
