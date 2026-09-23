import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/custom_fields/screens/custom_fields_controller.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:flutter/material.dart';

class CheckboxSelectionWidget extends StatefulWidget {
  const CheckboxSelectionWidget({required this.field, super.key});

  final CheckboxField field;

  @override
  State<CheckboxSelectionWidget> createState() =>
      _CheckboxSelectionWidgetState();
}

class _CheckboxSelectionWidgetState extends State<CheckboxSelectionWidget> {
  List<String> _selected = [];
  CustomFieldsController? _controller;

  @override
  Widget build(BuildContext context) {
    _controller ??= CustomFieldsControllerProvider.maybeOf(context)?.controller;
    _selected =
        _controller?.data[widget.field.id]?.value as List<String>? ?? [];
    return Wrap(
      spacing: 6,
      children: List.generate(widget.field.values.length, (index) {
        final value = widget.field.values[index];
        final selected = _selected.contains(value.canonical);
        return ChoiceChip(
          onSelected: (isSelected) {
            if (isSelected) {
              _selected.add(value.canonical);
            } else {
              _selected.remove(value.canonical);
            }
            setState(() {});
            _controller?.updateValue(widget.field.id, _selected);
          },
          showCheckmark: false,
          pressElevation: 0,
          backgroundColor: context.colorScheme.secondary,
          selectedColor: context.colorScheme.primary.withValues(alpha: .05),
          avatar: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              key: ValueKey(selected),
              selected ? AppIcons.check : AppIcons.plus,
              color: selected
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface,
            ),
          ),
          chipAnimationStyle: ChipAnimationStyle(
            selectAnimation: AnimationStyle.noAnimation,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: selected
                  ? context.colorScheme.primary
                  : context.theme.dividerColor,
            ),
          ),
          label: Text(value.localized),
          labelStyle: context.bodyLarge.withColor(
            selected
                ? context.colorScheme.primary
                : context.colorScheme.onSurface,
          ),
          selected: selected,
        );
      }),
    );
  }
}
