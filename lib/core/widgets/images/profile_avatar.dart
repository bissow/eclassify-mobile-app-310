import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    String? src,
    this.tag,
    this.size = const Size.square(200),
    this.errorImage,
    super.key,
  }) : src = src ?? '';

  final String src;
  final String? tag;
  final Size size;
  final Widget? errorImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (src.isNotEmpty) {
          Navigator.of(context).push(
            PageRouteBuilder(
              opaque: false,
              fullscreenDialog: true,
              barrierColor: Colors.black54,
              barrierDismissible: true,
              pageBuilder: (_, _, _) => Center(
                child: Hero(
                  tag: tag ?? src,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CustomImage(
                      src: src,
                      size: Size.square(200),
                      resolution: Size.square(200),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
      child: Hero(
        tag: tag ?? src,
        child: CircleAvatar(
          radius: size.height / 2,
          backgroundColor: context.colorScheme.primary,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size.height / 2),
            child: CustomImage(
              src: src,
              size: size,
              fit: BoxFit.cover,
              errorImage:
                  errorImage ??
                  CustomImage(
                    src: AppAssets.profile.profile,
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
