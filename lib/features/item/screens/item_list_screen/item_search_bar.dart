import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/utils/debounce_mixin.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_suggestion_box.dart';
import 'package:eClassify/features/item/storage/search_history_storage.dart';
import 'package:flutter/material.dart';

enum ItemDisplayType { list, grid }

class ItemSearchBar extends StatefulWidget implements PreferredSizeWidget {
  const ItemSearchBar({
    required this.onSearch,
    required this.displayType,
    this.autoFocus = true,
    this.showSuggestions = true,
    super.key,
  });

  final bool autoFocus;
  final ValueChanged<String?> onSearch;
  final ValueNotifier<ItemDisplayType> displayType;

  /// Whether recently-viewed-item suggestions can appear while typing.
  /// Only meaningful for a free-text search entry point — list screens
  /// reached via a category/featured section aren't "searching", so
  /// suggestions (and recording taps into search history) don't apply.
  final bool showSuggestions;

  @override
  State<ItemSearchBar> createState() => _ItemSearchBarState();

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _ItemSearchBarState extends State<ItemSearchBar>
    with DebounceMixin<ItemSearchBar, String?> {
  final TextEditingController _searchController = TextEditingController();
  late final FocusNode _focusNode = FocusNode(
    canRequestFocus: widget.autoFocus,
  );
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _overlayController = OverlayPortalController();

  // To avoid TextField losing focus when tapping on the suggestion overlay
  final Object _tapRegionGroupId = Object();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_syncOverlay);
    _searchController.addListener(_syncOverlay);
  }

  void _syncOverlay() {
    final shouldShow =
        widget.showSuggestions &&
        _focusNode.hasFocus &&
        _searchController.text.trim().isNotEmpty;
    if (shouldShow) {
      _overlayController.show();
    } else {
      _overlayController.hide();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void onDebounced(String? value) {
    if (value == null || value.isEmpty) {
      widget.onSearch(null);
    } else {
      widget.onSearch(value);
    }
  }

  void _submitQuery(String query) {
    final trimmed = query.trim();
    if (widget.showSuggestions && trimmed.isNotEmpty) {
      SearchHistoryStorage.addSearchHistory(trimmed);
    }
    widget.onSearch(query);
  }

  void _selectSuggestion(String query) {
    _searchController
      ..text = query
      ..selection = TextSelection.collapsed(offset: query.length);
    _focusNode.unfocus();
    _submitQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) => ItemSuggestionBox(
        layerLink: _layerLink,
        controller: _searchController,
        tapRegionGroupId: _tapRegionGroupId,
        onQuerySelected: _selectSuggestion,
      ),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Constant.horizontalPadding,
            vertical: 12,
          ),
          child: Row(
            spacing: 5,
            children: [
              Expanded(
                child: TextField(
                  groupId: _tapRegionGroupId,
                  focusNode: _focusNode,
                  autofocus: widget.autoFocus,
                  controller: _searchController,
                  onChanged: widget.showSuggestions ? null : debounce,
                  onSubmitted: _submitQuery,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    hintText: 'searchHint'.translate(context),
                    hintStyle: TextStyle(color: context.mutedColor),
                    prefixIcon: Icon(
                      AppIcons.magnifyingGlass,
                      color: context.colorScheme.primary,
                    ),
                    prefixIconConstraints: BoxConstraints.tight(
                      Size.square(38),
                    ),
                    constraints: BoxConstraints(maxHeight: 48),
                  ),
                  onTapOutside: (_) {
                    _focusNode.unfocus();
                  },
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  fixedSize: Size.square(48),
                ),
                onPressed: () =>
                    widget.displayType.value = ItemDisplayType.list,
                icon: ValueListenableBuilder(
                  valueListenable: widget.displayType,
                  builder: (context, value, child) {
                    final icon = value == ItemDisplayType.list
                        ? AppIcons.squareSplitVerticalFill
                        : AppIcons.squareSplitVertical;
                    return Icon(icon, color: context.colorScheme.onSurface);
                  },
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  fixedSize: Size.square(48),
                ),
                onPressed: () =>
                    widget.displayType.value = ItemDisplayType.grid,
                icon: ValueListenableBuilder(
                  valueListenable: widget.displayType,
                  builder: (context, value, child) {
                    final icon = value == ItemDisplayType.grid
                        ? AppIcons.gridFourFill
                        : AppIcons.gridFour;
                    return Icon(icon, color: context.colorScheme.onSurface);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
