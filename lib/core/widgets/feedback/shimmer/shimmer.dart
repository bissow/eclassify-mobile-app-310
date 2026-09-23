import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart' as pkg;

export 'package:shimmer/shimmer.dart';

export 'bone.dart';
export 'shimmer_container.dart';
export 'shimmer_flex.dart';
export 'shimmer_grid.dart';
export 'shimmer_grid_card.dart';
export 'shimmer_list.dart';
export 'shimmer_list_tile.dart';

/// Generic shimmer sweep over any [child]. Colors default to the theme's
/// surface-container tokens; override for one-off shapes (e.g. an audio
/// waveform placeholder) that don't go through [ShimmerContainer].
class Shimmer extends StatelessWidget {
  const Shimmer({
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.direction,
    super.key,
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final pkg.ShimmerDirection? direction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return pkg.Shimmer.fromColors(
      baseColor: baseColor ?? colorScheme.surfaceContainerHigh,
      highlightColor: highlightColor ?? colorScheme.surfaceContainer,
      direction: direction ?? pkg.ShimmerDirection.ltr,
      child: child,
    );
  }
}
