import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/features/advertisement/cubits/fetch_item_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/item_status_cubit.dart';
import 'package:eClassify/features/item/cubits/delete_item_cubit.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/extensions/item_extension.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/item/screens/widgets/modals/delete_advertisement_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerItemMenu extends StatelessWidget {
  const SellerItemMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final item = context.select<FetchItemCubit, MyItem?>(
      (c) => switch (c.state) {
        FetchItemSuccess(:final item) => item.isMyAd ? item as MyItem : null,
        _ => null,
      },
    );

    final shouldShowMenu = switch (item?.status) {
      ItemStatus.approved || ItemStatus.active => true,
      _ => false,
    };

    if (!shouldShowMenu) return const SizedBox.shrink();

    return BlocProvider(
      create: (context) => ItemStatusCubit(),
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              BlocListener<ItemStatusCubit, ItemStatusState>(
                listener: (context, state) {
                  if (state is ItemStatusLoading) {
                    LoadingOverlay.show(context);
                  }
                  if (state is ItemStatusSuccess) {
                    LoadingOverlay.hide();
                    context.read<FetchItemCubit>().fetchItem(
                      itemId: item!.id,
                      isMyAd: true,
                    );
                  }
                  if (state is ItemStatusFailure) {
                    LoadingOverlay.hide();
                  }
                },
              ),
              BlocListener<DeleteItemCubit, DeleteItemState>(
                listener: (context, state) {
                  if (state is DeleteItemLoading) {
                    LoadingOverlay.show(context);
                  }
                  if (state is DeleteItemSuccess) {
                    LoadingOverlay.hide();
                    HelperUtils.showSnackBarMessage(
                      context,
                      'itemDeletedSuccessfully'.translate(context),
                    );
                    Navigator.pop(context, true);
                  } else if (state is DeleteItemFailure) {
                    LoadingOverlay.hide();
                    HelperUtils.showSnackBarMessage(
                      context,
                      state.errorMessage,
                    );
                  }
                },
              ),
            ],
            child: PopupMenuButton(
              icon: Icon(AppIcons.dotsThreeVertical, size: 24),
              itemBuilder: (context) {
                return [
                  if (item!.status != ItemStatus.softRejected)
                    PopupMenuItem(
                      child: Text('deactivate'.translate(context)),
                      onTap: () {
                        context.read<ItemStatusCubit>().changeItemStatus(
                          itemId: item.id,
                          status: ItemStatus.inactive,
                        );
                      },
                    ),
                  PopupMenuItem(
                    child: Text('remove'.translate(context)),
                    onTap: () async {
                      final shouldDelete =
                          await DeleteAdvertisementDialog.show(context) ??
                          false;

                      if (shouldDelete) {
                        context.read<DeleteItemCubit>().deleteItem(id: item.id);
                      }
                    },
                  ),
                ];
              },
            ),
          );
        },
      ),
    );
  }
}
