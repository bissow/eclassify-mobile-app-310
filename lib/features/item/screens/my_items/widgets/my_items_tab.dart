import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/shimmer/shimmer.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/features/item/cubits/delete_item_cubit.dart';
import 'package:eClassify/features/item/cubits/my_items_cubit.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/features/notification/listeners/server_notification_listener.dart';
import 'package:eClassify/features/notification/models/server_notification.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyItemsTab extends StatefulWidget {
  const MyItemsTab({
    required this.status,
    required this.itemsToDelete,
    super.key,
  });

  final String? status;
  final SetNotifier<int> itemsToDelete;

  @override
  State<MyItemsTab> createState() => _MyItemsTabState();
}

class _MyItemsTabState extends State<MyItemsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Widget _shimmerList() {
    return ShimmerList(
      itemCount: 10,
      padding: EdgeInsets.symmetric(
        horizontal: Constant.horizontalPadding,
        vertical: 12,
      ),
      separator: 12.vGap,
      itemBuilder: (_, _) => ShimmerListTile(
        padding: EdgeInsetsDirectional.only(end: 16),
        backgroundColor: context.colorScheme.secondary,
        backgroundRadius: 16,
        leadingBone: const Bone.custom(width: 100, height: 120, radius: 16),
        lines: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return _MyItemScope(
      status: widget.status,
      child: ServerNotificationListener<ItemUpdateNotification>(
        onNotification: (context, notification) {
          if (notification.status == null ||
              notification.status != widget.status) {
            return;
          }
          context.read<MyItemsCubit>().get(reset: true);
        },
        child: BlocListener<DeleteItemCubit, DeleteItemState>(
          listener: (context, state) {
            if (state is DeleteItemSuccess) {
              context.read<MyItemsCubit>().deleteItemsLocally(state.deletedIds);
            }
          },
          child: PaginatedListView<MyItemsCubit, MyItemPreview, void>(
            padding: context.bodyPadding(),
            itemBuilder: (context, item) {
              return ListenableBuilder(
                listenable: widget.itemsToDelete,
                builder: (context, child) {
                  final selected = widget.itemsToDelete.contains(item.id);
                  return ItemCard.list(
                    item: item,
                    shape: selected
                        ? RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: context.colorScheme.primary,
                              width: 2,
                            ),
                          )
                        : null,
                    onTap: () async {
                      if (widget.itemsToDelete.isNotEmpty) {
                        widget.itemsToDelete.toggle(item.id);
                        return;
                      }
                      final didUpdate =
                          await Navigator.of(context).pushNamed(
                                Routes.adDetailsScreen,
                                arguments: {
                                  'preview': item,
                                  'item_id': item.id,
                                },
                              )
                              as bool?;

                      if (didUpdate ?? false) {
                        context.read<MyItemsCubit>().get(reset: true);
                      }
                    },
                    onLongPress: () {
                      if (item.status != ItemStatus.expired) return;
                      if (widget.itemsToDelete.isNotEmpty) return;
                      widget.itemsToDelete.add(item.id);
                    },
                  );
                },
              );
            },
            separatorBuilder: (_, _) => 10.vGap,
            loadingBuilder: (context, isPageLoading) {
              return isPageLoading
                  ? Center(child: LoadingIndicator())
                  : _shimmerList();
            },
          ),
        ),
      ),
    );
  }
}

class _MyItemScope extends StatelessWidget {
  const _MyItemScope({required this.status, required this.child});

  final String? status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyItemsCubit(status),
      child: Builder(builder: (context) => child),
    );
  }
}
