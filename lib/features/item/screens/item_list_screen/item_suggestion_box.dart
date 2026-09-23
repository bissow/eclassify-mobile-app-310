import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/features/item/models/recent_item.dart';
import 'package:eClassify/features/item/storage/recent_items_storage.dart';
import 'package:eClassify/features/item/storage/search_history_storage.dart';
import 'package:flutter/material.dart';

/// Search suggestions shown under [ItemSearchBar] while typing: recent
/// queries (tap re-runs the search) and recently opened items (tap goes
/// straight to that item), mirroring how most search UIs mix the two.
///
/// Both lists are read from Hive once, on open; typing filters the cached
/// lists locally rather than re-reading Hive per keystroke.
class ItemSuggestionBox extends StatefulWidget {
  const ItemSuggestionBox({
    required this.layerLink,
    required this.controller,
    required this.tapRegionGroupId,
    required this.onQuerySelected,
    super.key,
  });

  final LayerLink layerLink;
  final TextEditingController controller;

  /// Shared with the search field's [TextField.groupId] so taps on
  /// suggestions aren't treated as "outside" the field, which would
  /// unfocus (and thus hide) the overlay before the tap registers.
  final Object tapRegionGroupId;

  final ValueChanged<String> onQuerySelected;

  @override
  State<ItemSuggestionBox> createState() => _ItemSuggestionBoxState();
}

class _ItemSuggestionBoxState extends State<ItemSuggestionBox> {
  List<String> _queries = [];
  List<RecentItem> _items = [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onQueryChanged);
    _load();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onQueryChanged);
    super.dispose();
  }

  Future<void> _load() async {
    final queries = await SearchHistoryStorage.getSearchHistory();
    final items = await RecentItemsStorage.getRecentItems();
    if (!mounted) return;
    setState(() {
      _queries = queries.reversed.toList();
      _items = items.reversed.toList();
    });
  }

  void _onQueryChanged() => setState(() {});

  void _openItem(BuildContext context, RecentItem item) {
    Navigator.of(
      context,
    ).pushNamed(Routes.adDetailsScreen, arguments: {'item_id': item.id});
  }

  Future<void> _clearAll() async {
    await SearchHistoryStorage.clearSearchHistory();
    await RecentItemsStorage.clearRecentItems();
    if (!mounted) return;
    setState(() {
      _queries = [];
      _items = [];
    });
  }

  List<String> get _filteredQueries {
    final query = widget.controller.text.trim().toLowerCase();
    return _queries
        .where((q) => q.toLowerCase().contains(query))
        .take(5)
        .toList();
  }

  List<RecentItem> get _filteredItems {
    final query = widget.controller.text.trim().toLowerCase();
    return _items
        .where((item) => item.name.toLowerCase().contains(query))
        .take(5)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformFollower(
      link: widget.layerLink,
      showWhenUnlinked: false,
      targetAnchor: Alignment.bottomLeft,
      child: TapRegion(
        groupId: widget.tapRegionGroupId,
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
            ),
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(8),
              color: context.colorScheme.secondary,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 300),
                child: _buildContent(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final queries = _filteredQueries;
    final items = _filteredItems;
    if (queries.isEmpty && items.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  'recentSearches'.translate(context),
                  style: TextStyle(color: context.mutedColor),
                ),
              ),
              TextButton(
                onPressed: _clearAll,
                child: Text('clear'.translate(context)),
              ),
            ],
          ),
          for (final query in queries)
            ListTile(
              dense: true,
              leading: const Icon(Icons.history),
              title: Text(query),
              onTap: () => widget.onQuerySelected(query),
            ),
          for (final item in items)
            ListTile(
              dense: true,
              leading: const Icon(Icons.shopping_bag_outlined),
              title: Text(item.name),
              onTap: () => _openItem(context, item),
            ),
        ],
      ),
    );
  }
}
