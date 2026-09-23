import 'package:eClassify/core/models/user_placeholder.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:flutter/material.dart';

class UserPlaceholderImage extends StatelessWidget {
  const UserPlaceholderImage({
    this.size = const Size.square(24),
    this.radius = 12,
    this.placeholder,
    super.key,
  });

  final UserPlaceholder? placeholder;
  final Size size;
  final double radius;

  Color? _hexToColor(String? color) {
    if (color == null) return null;
    final hex = color.replaceAll('#', '');
    final r = int.parse('FF$hex', radix: 16);
    return Color(r);
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _hexToColor(placeholder?.avatarColor) ?? context.colorScheme.primary;
    final initial = placeholder?.initial;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox.fromSize(
        size: size,
        child: Center(
          child: initial.isNotNullAndNotEmpty
              ? Center(
                  child: Text(
                    initial!,
                    style: TextStyle(
                      fontSize: size.longestSide / 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : CustomImage(
                  src: AppAssets.profile.defaultPerson,
                  size: Size(size.width / 2, size.height / 2),
                  fit: BoxFit.cover,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }
}
