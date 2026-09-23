import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/utils/file_picker_utility.dart';
import 'package:flutter/material.dart';

class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({required this.profileImageNotifier, super.key});

  final ValueNotifier<FileResource?> profileImageNotifier;

  void _showImagePicker(BuildContext context) async {
    final files = await FilePickerUtility.pickWithSheet(
      context: context,
      showDocumentOption: false,
    );

    if (files.isNullOrEmpty) return;

    final file = files!.first;
    final resource = LocalFileResource(file);
    profileImageNotifier.value = resource;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.topCenter,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: context.colorScheme.primary, width: 2),
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ValueListenableBuilder<FileResource?>(
              valueListenable: profileImageNotifier,
              builder: (context, profile, child) {
                return ProfileAvatar(
                  src: profile?.filePath ?? '',
                  size: Size.square(100),
                  errorImage: UserPlaceholderImage(
                    placeholder: AppSession.currentUser!.placeholder,
                    size: Size.square(100),
                  ),
                );
              },
            ),
          ),
        ),
        PositionedDirectional(
          bottom: 4,
          end: 4,
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: context.colorScheme.primary,
              foregroundColor: context.colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              fixedSize: Size.square(32),
            ),
            onPressed: () => _showImagePicker(context),
            icon: Icon(AppIcons.pencilSimpleLine),
          ),
        ),
      ],
    );
  }
}
