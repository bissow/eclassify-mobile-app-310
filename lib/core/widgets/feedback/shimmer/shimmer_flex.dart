import 'package:flutter/material.dart';

/// Row/Column of shimmer blocks (or any widgets) with spacing — sizing comes
/// from the children's own bones/intrinsics, never fixed pixels here.
class ShimmerFlex extends StatelessWidget {
  final Axis direction;
  final List<Widget> children;
  final double spacing;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ShimmerFlex({
    super.key,
    required this.direction,
    required this.children,
    this.spacing = 8,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  const ShimmerFlex.horizontal({
    super.key,
    required this.children,
    this.spacing = 8,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : direction = Axis.horizontal;

  const ShimmerFlex.vertical({
    super.key,
    required this.children,
    this.spacing = 8,
    this.mainAxisSize = MainAxisSize.min,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : direction = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        spaced.add(
          direction == Axis.horizontal
              ? SizedBox(width: spacing)
              : SizedBox(height: spacing),
        );
      }
      spaced.add(children[i]);
    }

    return Flex(
      direction: direction,
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: spaced,
    );
  }
}
