import 'dart:io';

import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/surfaces/bottom_sheet_skeleton.dart';
import 'package:flutter/material.dart';

class ReceiptFileDisplaySheet {
  static Future<bool?> show(BuildContext context, File file) {
    return showModalBottomSheet<bool>(
      context: context,
      builder: (context) {
        return BottomSheetSkeleton(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 10,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8,
                children: [
                  Icon(AppIcons.fileFill),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          file.path.split('/').last,
                          style: context.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          file.lengthSync().formatBytes(),
                          style: context.bodySmall.withColor(
                            context.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppButton(
                variant: AppButtonVariant.filled,
                size: AppButtonSize.small,
                onPressed: () => Navigator.of(context).pop(true),
                title: 'upload',
              ),
            ],
          ),
        );
      },
    );
  }
}
