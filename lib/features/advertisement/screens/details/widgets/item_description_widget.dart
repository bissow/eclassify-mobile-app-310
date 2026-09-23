import 'package:eClassify/core/widgets/text/expandable_text.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class ItemDescriptionWidget extends StatelessWidget {
  const ItemDescriptionWidget({required this.description, super.key});

  final String? description;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (description == null) {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomShimmer(width: 200, height: 20, borderRadius: 16),
          12.vGap,
          ...List.generate(
            5,
            (_) => CustomShimmer(
              width: double.maxFinite,
              height: 20,
              borderRadius: 16,
              margin: EdgeInsets.symmetric(vertical: 2),
            ),
          ),
        ],
      );
    } else {
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            'aboutThisItem'.translate(context),
            style: context.titleMedium.semiBold,
          ),
          ExpandableText(
            text: description!,
            maxLines: 10,
            style: context.bodyMedium,
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: child,
    );
  }
}
