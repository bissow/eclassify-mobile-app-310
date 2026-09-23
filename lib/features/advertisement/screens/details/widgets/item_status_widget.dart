import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/text/expandable_text.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:flutter/material.dart';

class ItemStatusWidget extends StatelessWidget {
  const ItemStatusWidget({required this.item, super.key});

  final MyItem item;

  @override
  Widget build(BuildContext context) {
    final isSoftReject = item.status == ItemStatus.softRejected;
    final color = isSoftReject ? Colors.orange : Colors.red;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .2),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          CustomImage(
            src: isSoftReject
                ? AppAssets.common.softRejectedIcon
                : AppAssets.common.permanentRejectedIcon,
            color: color,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 4,
              children: [
                Text(
                  (isSoftReject
                          ? 'softRejectByAdmin'
                          : 'permanentRejectByAdmin')
                      .translate(context),
                  style: context.titleSmall,
                ),
                ExpandableText(
                  text: item.rejectedReason ?? '',
                  style: context.bodySmall,
                  readMoreButtonStyle: context.bodySmall.withColor(color),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
