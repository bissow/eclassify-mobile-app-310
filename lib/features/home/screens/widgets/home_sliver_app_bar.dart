import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/features/home/screens/widgets/category/all_category_widget.dart';
import 'package:eClassify/features/home/screens/widgets/location_widget.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:flutter/material.dart';

class HomeSliverAppBar extends StatelessWidget {
  const HomeSliverAppBar({super.key, required this.hasCategory});

  final bool hasCategory;

  @override
  Widget build(BuildContext context) {
    final bottomHeight = hasCategory ? 50.0 : 0.0;

    return SliverAppBar(
      backgroundColor: context.colorScheme.surface,
      pinned: true,
      floating: true,
      snap: true,
      toolbarHeight: kToolbarHeight,
      expandedHeight: kToolbarHeight + bottomHeight,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: ColoredBox(
          color: context.colorScheme.secondary,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: Row(
                      children: [
                        Expanded(child: LocationWidget()),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                              Routes.itemsList,
                              arguments: SearchMetaData(
                                title: 'search'.translate(context),
                              ),
                            );
                          },
                          icon: Icon(AppIcons.magnifyingGlass),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: hasCategory
          ? PreferredSize(
              preferredSize: Size.fromHeight(bottomHeight),
              child: ColoredBox(
                color: context.colorScheme.surface,
                child: const AllCategoryWidget(),
              ),
            )
          : null,
    );
  }
}
