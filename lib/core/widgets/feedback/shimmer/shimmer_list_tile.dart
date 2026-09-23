import 'package:eClassify/core/widgets/feedback/shimmer/bone.dart';
import 'package:eClassify/core/widgets/feedback/shimmer/shimmer_container.dart';
import 'package:eClassify/core/widgets/feedback/shimmer/shimmer_flex.dart';
import 'package:flutter/material.dart';

/// Placeholder mimicking a ListTile: optional leading block, N text lines,
/// optional trailing block. No manual height — driven by padding + bones.
class ShimmerListTile extends StatelessWidget {
  final Bone? leadingBone;
  final Bone? trailingBone;
  final int lines;
  final EdgeInsetsGeometry padding;
  final double gap;
  final Color? backgroundColor;
  final double backgroundRadius;

  const ShimmerListTile({
    super.key,
    this.leadingBone = const Bone.circle(size: 44),
    this.trailingBone,
    this.lines = 2,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.gap = 12,
    this.backgroundColor,
    this.backgroundRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: backgroundColor == null
          ? null
          : BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(backgroundRadius),
            ),
      child: ShimmerFlex.horizontal(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: gap,
        children: [
          if (leadingBone != null) ShimmerContainer(bone: leadingBone!),
          Expanded(
            child: ShimmerFlex.vertical(
              spacing: 6,
              children: List.generate(
                lines,
                (i) => ShimmerContainer(
                  bone: Bone.text(width: i == lines - 1 ? 120 : null),
                ),
              ),
            ),
          ),
          if (trailingBone != null) ShimmerContainer(bone: trailingBone!),
        ],
      ),
    );
  }
}
