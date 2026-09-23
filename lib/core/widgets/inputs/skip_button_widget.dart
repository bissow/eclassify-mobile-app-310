import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

class SkipButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const SkipButtonWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.tertiary.withValues(alpha: .2),
        foregroundColor: context.colorScheme.tertiary,
        shape: StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        minimumSize: const Size(70, 38),
      ),
      onPressed: onTap,
      child: Text('skip'.translate(context)),
    );
  }
}
