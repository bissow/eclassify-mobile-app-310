import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/item/screens/widgets/item_status_chip.dart';
import 'package:flutter/material.dart';

class ItemBasicDetails extends StatelessWidget {
  const ItemBasicDetails({this.item, this.preview, super.key});

  final Item? item;
  final ItemPreview? preview;

  String? get name => item?.name.localized ?? preview?.name;

  String? get price => item?.price ?? preview?.price;

  String? get address => item?.address.localized ?? preview?.address;

  DateTime? get postedAt => item?.postedAt ?? preview?.postedAt;

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (item == null && preview == null) {
      child = CustomShimmer(height: 100, borderRadius: 16);
    } else {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Row(
            children: [
              Expanded(child: Text(name ?? '', style: context.titleMedium)),
              if (item case MyItem item
                  when item.status != ItemStatus.soldOut && item.isJobItem)
                AppButton(
                  variant: AppButtonVariant.filled,
                  size: AppButtonSize.compact,
                  width: AppButtonWidth.content,
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      Routes.jobApplicationList,
                      arguments: {'itemId': item.id},
                    );
                  },
                  title: 'jobApplications',
                ),
            ],
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  price ?? 'contactForPrice'.translate(context),
                  style: context.titleMedium.copyWith(
                    color: context.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (item case MyItem item) ItemStatusChip(status: item.status),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Icon(
                AppIcons.mapPinLine,
                color: context.colorScheme.primary,
                size: 16,
              ),
              Expanded(child: Text(address ?? '', style: context.bodySmall)),
              Text(
                postedAt?.format(formatString: 'dd MMM, yyyy') ?? '',
                style: context.bodySmall,
              ),
            ],
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      child: child,
    );
  }
}
