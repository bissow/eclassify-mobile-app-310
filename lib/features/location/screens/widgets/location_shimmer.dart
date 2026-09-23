import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LocationShimmer extends StatelessWidget {
  const LocationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 15,
      separatorBuilder: (context, index) => 1.vGap,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: CustomShimmer.baseColor(context),
          highlightColor: CustomShimmer.highlightColor(context),
          child: Container(
            padding: EdgeInsets.all(5),
            width: double.maxFinite,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: context.mutedColor.withValues(alpha: 0.18),
              ),
            ),
          ),
        );
      },
    );
  }
}
