import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/utils/debounce_mixin.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class ChatSearchBar extends StatefulWidget {
  const ChatSearchBar({
    required this.onSearch,
    required this.onClear,
    super.key,
  });

  final ValueChanged<String?> onSearch;
  final VoidCallback onClear;

  @override
  State<ChatSearchBar> createState() => _ChatSearchBarState();
}

class _ChatSearchBarState extends State<ChatSearchBar>
    with DebounceMixin<ChatSearchBar, String?> {
  late final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void onDebounced(String? value) {
    if (value.isNullOrEmpty) {
      widget.onClear();
    } else {
      widget.onSearch(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: false,
      focusNode: _focusNode,
      controller: _searchController,
      onChanged: debounce,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: 'search'.translate(context),
        hintStyle: TextStyle(color: context.mutedColor),
        prefixIcon: Icon(
          AppIcons.magnifyingGlass,
          color: context.colorScheme.primary,
        ),
        suffixIcon: ListenableBuilder(
          listenable: _searchController,
          builder: (context, child) {
            return _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _searchController.clear();
                      widget.onClear();
                    },
                    icon: Icon(AppIcons.x, color: context.mutedColor),
                  )
                : const SizedBox.shrink();
          },
        ),
        prefixIconConstraints: BoxConstraints.tight(const Size.square(38)),
        constraints: const BoxConstraints(maxHeight: 48),
      ),
      onTapOutside: (_) {
        _focusNode.unfocus();
      },
    );
  }
}
