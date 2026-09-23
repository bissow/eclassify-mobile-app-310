import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

class LocationItem extends StatelessWidget {
  const LocationItem({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.leadingIcon,
    this.showTrailingIcon = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? leadingIcon;
  final bool showTrailingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colorScheme.secondary,
      child: ListTile(
        onTap: onTap,
        dense: true,
        tileColor: context.colorScheme.secondary,
        title: Text(
          title,
          textAlign: TextAlign.start,
          style: context.bodyMedium.semiBold,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                textAlign: TextAlign.start,
                style: context.bodySmall,
              )
            : null,
        leading: leadingIcon,
        trailing: showTrailingIcon
            ? SizedBox.square(
                dimension: 32,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.mutedColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    AppIcons.caretRight,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
