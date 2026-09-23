import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/images/full_screen_image_view.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/custom_fields/enums/custom_field_type.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:flutter/material.dart';

typedef CustomFieldsByFieldId = Map<int, Map<int, ItemCustomField>>;

class CustomFieldsWidget extends StatelessWidget {
  const CustomFieldsWidget({required this.fields, super.key});

  final CustomFieldsByFieldId fields;

  @override
  Widget build(BuildContext context) {
    final currentLanguageId = AppSession.currentLanguage?.id;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 8,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            columnWidths: {
              0: FractionColumnWidth(.4),
              1: IntrinsicColumnWidth(),
              2: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: fields.values.map((field) {
              final effectiveField =
                  field[currentLanguageId] ?? field.entries.first.value;
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      spacing: 4,
                      children: [
                        CustomImage(
                          src: effectiveField.image,
                          size: Size.square(24),
                          fit: BoxFit.contain,
                          color: context.colorScheme.onSurface,
                        ),
                        Flexible(
                          child: Text(
                            effectiveField.name,
                            style: context.bodySmall.withColor(
                              context.mutedColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(':', style: context.titleMedium),
                  ),
                  if (effectiveField.type != CustomFieldType.file)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Text(
                        (effectiveField.translatedValue as List<dynamic>).join(
                          ', ',
                        ),
                        style: context.labelLarge,
                      ),
                    )
                  else
                    AppButton(
                      variant: AppButtonVariant.text,
                      width: AppButtonWidth.content,
                      size: AppButtonSize.compact,
                      style: ButtonStyle(
                        alignment: AlignmentDirectional.centerStart,
                        visualDensity: VisualDensity.compact,
                        padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        overlayColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        final file = effectiveField.value as String;
                        final isPdf = file.endsWith('pdf');
                        if (isPdf) {
                          Navigator.of(
                            context,
                          ).pushNamed(Routes.pdfViewerScreen, arguments: file);
                        } else {
                          FullScreenImageView.show(context, file);
                        }
                      },
                      child: Text('viewFile'.translate(context)),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
