import 'package:eClassify/app/widgets/bottom_navigation_bar/app_fab.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/core/widgets/layout/app_tab_bar.dart';
import 'package:eClassify/features/item/cubits/delete_item_cubit.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/screens/my_items/widgets/my_items_tab.dart';
import 'package:eClassify/features/item/screens/widgets/modals/delete_advertisement_dialog.dart';
import 'package:eClassify/features/notification/cubits/notification_event_cubit.dart';
import 'package:eClassify/features/subscription/cubits/user_package_limit_cubit.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyItemsScreen extends StatefulWidget {
  const MyItemsScreen({super.key});

  @override
  State<MyItemsScreen> createState() => _MyItemsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => const MyItemsScreen(),
    );
  }
}

class _MyItemsScreenState extends State<MyItemsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final Map<String, String?> _filters;
  final SetNotifier<int> _itemsToDelete = SetNotifier();

  @override
  void initState() {
    super.initState();

    final effectiveStatus = List<ItemStatus>.from(ItemStatus.values)
      ..removeWhere((status) => status == ItemStatus.unknown);

    _filters = {
      'allAds': null,
      'featured': 'featured',
      for (final s in effectiveStatus) s.name: s.value,
    };

    _tabController = TabController(length: _filters.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _itemsToDelete.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NotificationListener(
      onStatusChanged: (status) {
        final index = _filters.values.toList().indexOf(status);
        if (index == -1) return;
        _tabController.animateTo(index);
      },
      child: BlocListener<DeleteItemCubit, DeleteItemState>(
        listener: (context, state) {
          if (state is DeleteItemLoading) {
            LoadingOverlay.show(context);
          }
          if (state is DeleteItemSuccess) {
            LoadingOverlay.hide();
            _itemsToDelete.clear();
            HelperUtils.showSnackBarMessage(
              context,
              "deletedSuccessfully".translate(context),
            );
          }
          if (state is DeleteItemFailure) {
            LoadingOverlay.hide();
            HelperUtils.showSnackBarMessage(context, state.errorMessage);
          }
        },
        child: AppScaffold(
          floatingActionButton: BlocProvider(
            create: (_) => UserPackageLimitCubit(),
            child: const AppFab(
              type: FabType.material,
              heroTag: 'myItemsFab',
            ),
          ),
          appBar: AppBar(
            title: Text('myAds'.translate(context)),
            bottom: AppTabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: _filters.keys.toList(),
            ),
            actions: [
              ListenableBuilder(
                listenable: _itemsToDelete,
                builder: (context, child) {
                  return _itemsToDelete.isNotEmpty
                      ? child!
                      : const SizedBox.shrink();
                },
                child: IconButton(
                  onPressed: () async {
                    final didDelete =
                        await DeleteAdvertisementDialog.show(context) ?? false;
                    if (didDelete) {
                      context.read<DeleteItemCubit>().deleteMultiItem(
                        ids: _itemsToDelete.value,
                      );
                    }
                  },
                  icon: Icon(AppIcons.trash),
                ),
              ),
              IconButton(
                tooltip: 'promotionsPerformance'.translate(context),
                onPressed: () {
                  Navigator.pushNamed(context, Routes.sellerPromotions);
                },
                icon: Icon(AppIcons.trendUp),
              ),
            ],
          ),

          body: TabBarView(
            controller: _tabController,
            children: [
              ..._filters.values.map(
                (status) =>
                    MyItemsTab(status: status, itemsToDelete: _itemsToDelete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationListener extends StatelessWidget {
  const _NotificationListener({
    required this.child,
    required this.onStatusChanged,
  });

  final Widget child;
  final ValueChanged<String?> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return BlocListener<NotificationEventCubit, NotificationEventState>(
      listener: (context, state) {
        if (state is BackgroundNotificationReceived) {
          final status = state.remoteMessage?.data['status'];
          onStatusChanged(status);
        }
        if (state is ForegroundNotificationActionReceived) {
          final status = state.payload['status'];
          onStatusChanged(status);
        }
      },
      child: child,
    );
  }
}
