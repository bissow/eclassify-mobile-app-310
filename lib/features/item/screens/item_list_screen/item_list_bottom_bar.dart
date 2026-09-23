import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/item/models/item_filter.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:flutter/material.dart';

class ItemListBottomBar extends StatelessWidget {
  const ItemListBottomBar({
    required this.metadata,
    required this.onSortChanged,
    required this.onFilterChanged,
    super.key,
  });

  final ItemMetaData metadata;
  final ValueChanged<Sort> onSortChanged;
  final ValueChanged<ItemFilter?> onFilterChanged;

  void _showSortByBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      backgroundColor: context.colorScheme.secondary,
      builder: (context) {
        return Padding(
          padding: MediaQuery.paddingOf(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: Sort.values
                .map(
                  (sort) => ListTile(
                    onTap: () {
                      onSortChanged(sort);
                      Navigator.of(context).pop();
                    },
                    title: Text(sort.label.translate(context)),
                    trailing: metadata.sortBy == sort
                        ? Icon(
                            AppIcons.check,
                            color: context.colorScheme.primary,
                          )
                        : null,
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double bottomNavHeight = kBottomNavigationBarHeight;
    bottomNavHeight += MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: bottomNavHeight,
      child: ColoredBox(
        color: context.colorScheme.secondary,
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.text,
                  foregroundColor: context.colorScheme.onSurface,
                  onPressed: () async {
                    final filter =
                        await Navigator.of(context).pushNamed(
                              Routes.filterScreen,
                              arguments: {
                                'filter': metadata.filter,
                                'show_category_filter':
                                    metadata is! CategoryMetaData,
                              },
                            )
                            as ItemFilter?;
                    onFilterChanged(filter);
                  },
                  icon: Icon(AppIcons.sliders),
                  title: 'filterTitle',
                ),
              ),
              Expanded(
                child: AppButton(
                  variant: AppButtonVariant.text,
                  foregroundColor: context.colorScheme.onSurface,
                  onPressed: () => _showSortByBottomSheet(context),
                  icon: Icon(AppIcons.funnelSimple),
                  title: 'sortBy',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
