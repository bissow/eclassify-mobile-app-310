import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/profile/models/menu_item.dart';
import 'package:eClassify/features/profile/models/menu_item_action.dart';
import 'package:eClassify/core/widgets/text/auto_size_text.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class MyActivitySection extends StatelessWidget {
  MyActivitySection({super.key});

  final items = [
    MenuItem(
      icon: AppIcons.shoppingBagOpen,
      title: 'myAds',
      action: ScreenPushAction(route: Routes.myItemScreen, guarded: true),
    ),
    MenuItem(
      icon: AppIcons.heart,
      title: 'favorites',
      action: ScreenPushAction(route: Routes.favoritesScreen, guarded: true),
    ),
    MenuItem(
      icon: AppIcons.notepad,
      title: 'jobApplications',
      action: ScreenPushAction(
        route: Routes.jobApplicationList,
        guarded: true,
        args: {'isMyJobApplications': true},
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size.fromHeight(80)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: items.map((item) {
          return Expanded(
            child: GestureDetector(
              onTap: () => item.action.execute(context),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: context.colorScheme.secondary,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 8,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: context.colorScheme.surface,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(item.icon, size: 20),
                      ),
                    ),
                    AutoSizeText(
                      text: item.title.translate(context),
                      style: context.labelMedium,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
