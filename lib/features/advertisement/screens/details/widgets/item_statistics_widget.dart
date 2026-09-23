import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:flutter/material.dart';

class ItemStatisticsWidget extends StatelessWidget {
  const ItemStatisticsWidget({
    required this.views,
    required this.likes,
    super.key,
  });

  final int views;
  final int likes;

  Widget _buildStat(BuildContext context, IconData icon, int value) {
    return Expanded(
      child: ConstrainedBox(
        constraints: BoxConstraints.tight(Size.fromHeight(50)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 8,
            children: [Icon(icon), Text(value.compact)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 16,
        children: [
          _buildStat(context, AppIcons.eye, views),
          _buildStat(context, AppIcons.heart, likes),
        ],
      ),
    );
  }
}
