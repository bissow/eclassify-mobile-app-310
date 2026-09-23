import 'package:flutter/material.dart';

import 'package:eClassify/core/widgets/feedback/shimmer/bone.dart';
import 'package:eClassify/core/widgets/feedback/shimmer/shimmer_container.dart';
import 'package:eClassify/core/widgets/feedback/shimmer/shimmer_flex.dart';

/// Placeholder mimicking a card: image block (via AspectRatio, no fixed
/// height) + N text lines below.
class ShimmerGridCard extends StatelessWidget {
  final double imageAspectRatio;
  final int textLines;
  final double imageBorderRadius;
  final double gap;
  final Color? backgroundColor;
  final double backgroundRadius;
  final EdgeInsetsGeometry padding;

  const ShimmerGridCard({
    super.key,
    this.imageAspectRatio = 1,
    this.textLines = 2,
    this.imageBorderRadius = 12,
    this.gap = 8,
    this.backgroundColor,
    this.backgroundRadius = 12,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final content = ShimmerFlex.vertical(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: gap,
      children: [
        AspectRatio(
          aspectRatio: imageAspectRatio,
          child: ShimmerContainer(
            bone: Bone.custom(height: double.infinity, radius: imageBorderRadius),
          ),
        ),
        ...List.generate(
          textLines,
          (i) => ShimmerContainer(
            bone: Bone.text(width: i == textLines - 1 ? 60 : null),
          ),
        ),
      ],
    );

    if (backgroundColor == null) return content;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(backgroundRadius),
      ),
      child: content,
    );
  }
}
