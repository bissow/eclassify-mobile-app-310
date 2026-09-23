import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          Routes.itemsList,
          arguments: SearchMetaData(title: 'search'.translate(context)),
        );
      },
      child: Container(
        margin: Constant.pagePadding.copyWith(top: 16, bottom: 5),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.colorScheme.surfaceContainerHigh),
        ),
        constraints: BoxConstraints(maxHeight: 48),
        child: Row(
          spacing: 10,
          children: [
            Icon(AppIcons.magnifyingGlass, color: context.colorScheme.primary),
            Expanded(
              child: Text(
                'searchHint'.translate(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodyLarge.withColor(context.mutedColor),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Navigator.pushNamed(context, Routes.nearbyStores);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.storefront,
                      size: 16,
                      color: context.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
