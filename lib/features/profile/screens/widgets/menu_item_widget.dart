import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/features/profile/models/menu_item.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

class MenuItemWidget extends StatelessWidget {
  const MenuItemWidget({
    required this.item,
    this.dense = true,
    this.visualDensity = VisualDensity.compact,
    this.shape = const LinearBorder(),
    this.tileColor = Colors.transparent,
    this.contentPadding = EdgeInsets.zero,
    super.key,
  });

  final MenuItem item;
  final bool dense;
  final VisualDensity visualDensity;
  final ShapeBorder shape;
  final Color? tileColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: dense,
      visualDensity: visualDensity,
      shape: shape,
      splashColor: Colors.transparent,
      tileColor: tileColor,
      contentPadding: contentPadding,
      onTap: () => item.action.execute(context),
      leading: Icon(item.icon),
      title: Text(item.title.translate(context)),
      titleTextStyle: context.titleSmall,
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: item.showTrailing
          ? item.trailing ?? Icon(AppIcons.caretRight)
          : null,
    );
  }
}
