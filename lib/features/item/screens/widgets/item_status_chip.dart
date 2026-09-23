import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class ItemStatusChip extends StatelessWidget {
  const ItemStatusChip({required this.status, super.key});

  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          status.label.translate(context),
          style: context.bodySmall.withColor(status.color),
        ),
      ),
    );
  }
}

class ItemEditedChip extends StatelessWidget {
  const ItemEditedChip({super.key});

  @override
  Widget build(BuildContext context) {
    final color = StatusColors.errorMessageColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          'adminEdited'.translate(context),
          style: context.bodySmall.withColor(color),
        ),
      ),
    );
  }
}
