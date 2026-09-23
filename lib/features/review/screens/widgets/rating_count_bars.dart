import 'package:collection/collection.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class RatingCountBars extends StatelessWidget {
  const RatingCountBars({required this.ratingCount, super.key});

  final Map<String, int> ratingCount;

  @override
  Widget build(BuildContext context) {
    final total = ratingCount.values.sum;

    return Column(
      children: List.generate(5, (index) {
        final rating = 5 - index;
        return _RatingBar(
          rating: rating,
          count: ratingCount[rating.toString()] ?? 0,
          total: total,
        );
      }),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.rating,
    required this.count,
    required this.total,
  });

  final int rating;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percentage = total == 0 ? 0.0 : count / total;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 10,
          child: Text(rating.toString(), style: context.labelMedium),
        ),
        2.hGap,
        Icon(AppIcons.starFill, color: Colors.amber, size: 12),
        16.hGap,
        Expanded(
          child: TweenAnimationBuilder(
            tween: Tween(begin: 0.0, end: percentage),
            duration: const Duration(milliseconds: 400),
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                color: Colors.amber,
                backgroundColor: context.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                minHeight: 8,
              );
            },
          ),
        ),
        12.hGap,
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 20),
          child: Center(child: Text(count.compact, style: context.labelMedium)),
        ),
      ],
    );
  }
}
