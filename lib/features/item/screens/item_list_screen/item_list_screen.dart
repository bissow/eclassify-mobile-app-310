import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/features/item/cubits/item_list_cubit.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/models/recent_item.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_list_bottom_bar.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_search_bar.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/features/item/storage/recent_items_storage.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemListScreen extends StatefulWidget {
  const ItemListScreen({required this.metadata, super.key});

  final ItemMetaData metadata;

  @override
  State<ItemListScreen> createState() => _ItemListScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => ItemListCubit(),
        child: ItemListScreen(
          metadata: routeSettings.arguments as ItemMetaData,
        ),
      ),
    );
  }
}

class _ItemListScreenState extends State<ItemListScreen> {
  late ItemMetaData metadata = widget.metadata;
  final ValueNotifier<ItemDisplayType> _displayType = ValueNotifier(
    ItemDisplayType.list,
  );
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  bool get isForSearch => metadata is SearchMetaData;

  @override
  void initState() {
    super.initState();
    metadata = metadata.copyWith(
      clearSortBy: true,
      filter: metadata.filter.copyWith(location: AppSession.currentLocation),
    );
  }

  @override
  void dispose() {
    _isLoading.dispose();
    _displayType.dispose();
    super.dispose();
  }

  void _recordRecentItem(ItemPreview item) {
    if (!isForSearch) return;
    RecentItemsStorage.addRecentItem(RecentItem.fromItem(item));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.secondary,
        title: Text(metadata.title),
        bottom: ItemSearchBar(
          autoFocus: isForSearch,
          showSuggestions: isForSearch,
          onSearch: (query) {
            metadata = metadata.copyWith(
              clearSearch: query.isNullOrEmpty,
              search: query,
            );
            setState(() {});
          },
          displayType: _displayType,
        ),
      ),
      bottomNavigationBar: ItemListBottomBar(
        metadata: metadata,
        onSortChanged: (value) {
          metadata = metadata.copyWith(sortBy: value);
          setState(() {});
        },
        onFilterChanged: (filter) {
          if (filter == null) return;
          metadata = metadata.copyWith(filter: filter);
          setState(() {});
        },
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
        child: ValueListenableBuilder(
          valueListenable: _displayType,
          builder: (context, display, child) {
            if (display == ItemDisplayType.list) {
              return PaginatedListView<
                ItemListCubit,
                ItemPreview,
                ItemMetaData
              >(
                parameters: metadata,
                padding: EdgeInsets.symmetric(vertical: 20),
                loadingBuilder: (context, isPageLoading) {
                  return isPageLoading
                      ? const LoadingIndicator.spinner()
                      : _buildItemsShimmer(context);
                },
                separatorBuilder: (_, _) => 8.vGap,
                itemBuilder: (context, item) {
                  return ItemCard.list(
                    item: item,
                    onTap: () {
                      _recordRecentItem(item);
                      Navigator.of(context).pushNamed(
                        Routes.adDetailsScreen,
                        arguments: {'item_id': item.id, 'preview': item},
                      );
                    },
                  );
                },
              );
            } else {
              return PaginatedGridView<
                ItemListCubit,
                ItemPreview,
                ItemMetaData
              >(
                parameters: metadata,
                padding: EdgeInsets.symmetric(vertical: 20),
                loadingBuilder: (context, isPageLoading) {
                  return isPageLoading
                      ? const LoadingIndicator.spinner()
                      : _buildGridItemsShimmer(context);
                },
                itemBuilder: (context, item) {
                  return ItemCard.grid(
                    item: item,
                    onTap: () {
                      _recordRecentItem(item);
                      Navigator.of(context).pushNamed(
                        Routes.adDetailsScreen,
                        arguments: {'item_id': item.id, 'preview': item},
                      );
                    },
                  );
                },
                gridDelegate: ItemCard.gridDelegate(context, spacing: 15),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildItemsShimmer(BuildContext context) {
    return ListView.separated(
      itemCount: 10,
      padding: EdgeInsets.symmetric(vertical: 20),
      separatorBuilder: (_, _) => 10.vGap,
      itemBuilder: (context, index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            spacing: 10,
            children: [
              CustomShimmer(height: 120, width: 100),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 10,
                children: [
                  CustomShimmer(width: 100, height: 10, borderRadius: 7),
                  CustomShimmer(width: 150, height: 10, borderRadius: 7),
                  CustomShimmer(width: 120, height: 10, borderRadius: 7),
                  CustomShimmer(width: 80, height: 10, borderRadius: 7),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridItemsShimmer(BuildContext context) {
    return GridView.count(
      padding: EdgeInsets.symmetric(vertical: 20),
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      childAspectRatio: .7,
      children: List.generate(6, (index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.secondary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: CustomShimmer(borderRadius: 18)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CustomShimmer(width: 80, height: 10, borderRadius: 7),
                      CustomShimmer(width: 120, height: 10, borderRadius: 7),
                      CustomShimmer(width: 100, height: 10, borderRadius: 7),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
