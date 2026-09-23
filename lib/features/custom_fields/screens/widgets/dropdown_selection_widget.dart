import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/core/models/localized_string.dart';
import 'package:eClassify/features/custom_fields/screens/custom_fields_controller.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class DropdownSelectionWidget extends StatefulWidget {
  const DropdownSelectionWidget({required this.field, super.key});

  final DropdownField field;

  @override
  State<DropdownSelectionWidget> createState() =>
      _DropdownSelectionWidgetState();
}

class _DropdownSelectionWidgetState extends State<DropdownSelectionWidget> {
  String? _selected;
  CustomFieldsController? _controller;

  void _openBottomSheet() async {
    // FocusScope.unfocus() only moves *primary* focus away — the ambient
    // scope still remembers whichever descendant was last focused (that
    // memory is what IndexedStack/PageView use to restore focus later), and
    // that memory survives an outside tap. When the sheet's own focus scope
    // releases focus back down on close, the stale memory resurrects that
    // field and its keyboard. Handing focus to a throwaway, unattached node
    // overwrites that memory instead of just stepping away from it.
    FocusScope.of(context).requestFocus(FocusNode());
    final selected = await showModalBottomSheet<LocalizedString>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(ctx).height * .5,
            maxHeight: MediaQuery.sizeOf(ctx).height * .7,
          ),
          child: _DropdownValuesList(
            values: widget.field.values,
            selected: _selected,
          ),
        ),
      ),
    );

    if (selected == null) return;

    setState(() {
      _selected = selected.canonical;
    });
    _controller?.updateValue(widget.field.id, _selected);
  }

  @override
  Widget build(BuildContext context) {
    _controller ??= CustomFieldsControllerProvider.maybeOf(context)?.controller;
    _selected = _controller?.data[widget.field.id]?.value as String?;
    final inputDecoration = context.theme.inputDecorationTheme;
    return GestureDetector(
      onTap: _openBottomSheet,
      child: ConstrainedBox(
        constraints:
            inputDecoration.constraints ??
            BoxConstraints.tight(Size.fromHeight(56)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: inputDecoration.fillColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding:
                inputDecoration.contentPadding ??
                EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _selected ?? widget.field.name.localized,
                style: _selected == null
                    ? inputDecoration.hintStyle
                    : context.titleMedium,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownValuesList extends StatefulWidget {
  const _DropdownValuesList({required this.values, required this.selected});

  final List<LocalizedString> values;
  final String? selected;

  @override
  State<_DropdownValuesList> createState() => _DropdownValuesListState();
}

class _DropdownValuesListState extends State<_DropdownValuesList> {
  late final ListNotifier<LocalizedString> _values = ListNotifier(
    widget.values,
  );

  @override
  void dispose() {
    _values.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: Constant.verticalPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
              ),
              child: TextField(
                onChanged: (value) {
                  if (value.isNullOrEmpty) {
                    _values.replaceAll(widget.values);
                    return;
                  }
                  final filtered = widget.values
                      .where(
                        (element) => element.localized.toLowerCase().contains(
                          value.toLowerCase(),
                        ),
                      )
                      .toList();
                  _values.replaceAll(filtered);
                },
                decoration: InputDecoration(
                  hintText: 'search'.translate(context),
                ),
              ),
            ),
            Flexible(
              child: Material(
                color: Colors.transparent,
                child: ListenableBuilder(
                  listenable: _values,
                  builder: (context, child) {
                    if (_values.isEmpty) {
                      return Center(
                        child: Text('nodatafound'.translate(context)),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final value = _values[index];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: Constant.horizontalPadding,
                          ),
                          title: Text(
                            value.localized,
                            style: context.titleSmall,
                          ),
                          onTap: () => Navigator.of(context).pop(value),
                          trailing: widget.selected == value.canonical
                              ? Icon(
                                  AppIcons.check,
                                  color: context.colorScheme.primary,
                                )
                              : null,
                        );
                      },
                      separatorBuilder: (_, _) => const Divider(),
                      itemCount: _values.length,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
