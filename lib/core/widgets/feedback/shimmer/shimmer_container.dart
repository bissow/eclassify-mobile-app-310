import 'package:flutter/material.dart';

import 'package:eClassify/core/widgets/feedback/shimmer/shimmer.dart';

/// A [Bone]-shaped shimmer block. The generic placeholder primitive —
/// compose these into layouts instead of hardcoding width/height per screen.
class ShimmerContainer extends StatelessWidget {
  final Bone bone;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerContainer({
    super.key,
    required this.bone,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: bone.width ?? double.infinity,
        height: bone.height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(bone.radius),
        ),
      ),
    );
  }
}
