import 'dart:io';

import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:flutter/material.dart';

class AttachmentPreview extends StatelessWidget {
  const AttachmentPreview({
    required this.file,
    required this.onRemove,
    super.key,
  });

  final File file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final fileName = file.path.split('/').last;
    final isImage = [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
    ].any((ext) => fileName.toLowerCase().endsWith(ext));

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: Constant.horizontalPadding,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colorScheme.outline),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: isImage
                ? CustomImage(src: file.path, radius: 4)
                : DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surface.withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      AppIcons.fileFill,
                      color: context.colorScheme.surface,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.bodySmall,
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(AppIcons.x, size: 20),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
