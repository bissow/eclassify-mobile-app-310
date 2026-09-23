import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:flutter/material.dart';

class FeaturedSectionHeader extends StatelessWidget {
  const FeaturedSectionHeader({
    super.key,
    required this.id,
    required this.title,
  });

  final int id;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(title, style: context.titleMedium, maxLines: 1)),
        AppButton(
          variant: AppButtonVariant.text,
          width: AppButtonWidth.content,
          size: AppButtonSize.small,
          textStyle: context.labelMedium,
          onPressed: () {
            Navigator.of(context).pushNamed(
              Routes.itemsList,
              arguments: SectionMetaData(sectionId: id, title: title),
            );
          },
          title: 'seeAll',
        ),
      ],
    );
  }
}
