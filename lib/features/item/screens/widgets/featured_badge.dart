import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class FeaturedBadge extends StatelessWidget {
  const FeaturedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: context.colorScheme.primary,
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Text(
          'featured'.translate(context),
          style: context.labelMedium.withColor(context.colorScheme.onPrimary),
        ),
      ),
    );
  }
}
