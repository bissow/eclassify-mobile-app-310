import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/advertisement/cubits/fetch_item_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/item_status_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/renew_item_cubit.dart';
import 'package:eClassify/features/item/cubits/delete_item_cubit.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/extensions/item_extension.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/item/screens/widgets/modals/delete_advertisement_dialog.dart';
import 'package:eClassify/features/subscription/screens/widgets/package_select_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef _IsLoadingPredicate = bool Function();

class SellerItemActions extends StatefulWidget {
  const SellerItemActions({required this.item, super.key});

  final MyItem item;

  @override
  State<SellerItemActions> createState() => _SellerItemActionsState();
}

class _SellerItemActionsState extends State<SellerItemActions> {
  ItemStatus get status => widget.item.status;

  bool get showEditButton {
    return switch (status) {
      ItemStatus.approved ||
      ItemStatus.review ||
      ItemStatus.softRejected ||
      ItemStatus.resubmitted => true,
      _ => false,
    };
  }

  bool get showDeleteButton {
    return switch (status) {
      ItemStatus.approved => false,
      _ => true,
    };
  }

  bool get showRenewButton => status == ItemStatus.expired;

  bool get showActivateButton => status == ItemStatus.inactive;

  bool get showSoldOutButton => status == ItemStatus.approved;

  bool _isAnyActionLoading() {
    final isRenewLoading =
        context.read<RenewItemCubit>().state is RenewItemLoading;
    final isItemStatusLoading =
        context.read<ItemStatusCubit>().state is ItemStatusLoading;
    final isRemoveItemLoading =
        context.read<DeleteItemCubit>().state is DeleteItemLoading;
    return isRenewLoading || isItemStatusLoading || isRemoveItemLoading;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        if (showEditButton) Expanded(child: _EditItemButton(item: widget.item)),
        if (showRenewButton)
          Expanded(
            child: _RenewItemButton(
              item: widget.item,
              isLoading: _isAnyActionLoading,
            ),
          ),
        if (showActivateButton)
          Expanded(
            child: _StatusChangeButton(
              itemId: widget.item.id,
              status: ItemStatus.active,
              isLoading: _isAnyActionLoading,
            ),
          ),
        if (showDeleteButton)
          Expanded(
            child: _RemoveItemButton(
              itemId: widget.item.id,
              isLoading: _isAnyActionLoading,
            ),
          ),
        if (showSoldOutButton)
          Expanded(
            child: _SoldOutButton(
              item: widget.item,
              isLoading: _isAnyActionLoading,
            ),
          ),
      ],
    );
  }
}

class _EditItemButton extends StatelessWidget {
  const _EditItemButton({required this.item});

  final MyItem item;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      variant: AppButtonVariant.outlined,
      onPressed: () async {
        final didEdit =
            await Navigator.of(context).pushNamed(
                  Routes.adPostingScreen,
                  arguments: item.toAdPostingData(),
                )
                as bool? ??
            false;
        if (didEdit) {
          context.read<FetchItemCubit>().fetchItem(
            itemId: item.id,
            isMyAd: true,
          );
        }
      },
      title: 'edit',
    );
  }
}

class _RenewItemButton extends StatelessWidget {
  const _RenewItemButton({required this.item, required this.isLoading});

  final MyItem item;
  final _IsLoadingPredicate isLoading;

  @override
  Widget build(BuildContext context) {
    return BlocListener<RenewItemCubit, RenewItemState>(
      listener: (context, state) {
        if (state is RenewItemSuccess) {
          context.read<FetchItemCubit>().fetchItem(
            itemId: item.id,
            isMyAd: true,
          );
          HelperUtils.showSnackBarMessage(context, state.responseMessage);
        }
        if (state is RenewItemFailure) {
          HelperUtils.showSnackBarMessage(context, state.errorMessage);
        }
      },
      child: AppButton(
        variant: AppButtonVariant.outlined,
        onPressed: () async {
          if (isLoading.call()) return;
          final isFreeAdListingEnabled =
              Constant.systemSettings.isFreeAdListingEnabled;
          if (isFreeAdListingEnabled) {
            context.read<RenewItemCubit>().renewItem(itemId: item.id);
          } else {
            PackageSelectBottomSheet.show(
              context,
              (packageId) {
                if (packageId == null) return;
                context.read<RenewItemCubit>().renewItem(
                  packageId: packageId,
                  itemId: item.id,
                );
              },
              category: item.category,
              adItemType: item.type,
            );
          }
        },
        child: BlocBuilder<RenewItemCubit, RenewItemState>(
          builder: (context, state) {
            if (state is RenewItemLoading) {
              return const LoadingIndicator.inlineDots();
            }
            return Text('renew'.translate(context));
          },
        ),
      ),
    );
  }
}

class _StatusChangeButton extends StatelessWidget {
  const _StatusChangeButton({
    required this.itemId,
    required this.status,
    required this.isLoading,
  });

  final int itemId;
  final ItemStatus status;
  final _IsLoadingPredicate isLoading;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemStatusCubit, ItemStatusState>(
      listener: (context, state) {
        if (state is ItemStatusSuccess) {
          context.read<FetchItemCubit>().fetchItem(
            itemId: itemId,
            isMyAd: true,
          );
          if (state.message.isNotNullAndNotEmpty) {
            HelperUtils.showSnackBarMessage(context, state.message!);
          }
        } else if (state is ItemStatusFailure) {
          HelperUtils.showSnackBarMessage(context, state.message);
        }
      },
      child: AppButton(
        variant: AppButtonVariant.filled,
        onPressed: () {
          if (isLoading.call()) return;
          context.read<ItemStatusCubit>().changeItemStatus(
            itemId: itemId,
            status: status,
          );
        },
        child: BlocBuilder<ItemStatusCubit, ItemStatusState>(
          builder: (context, state) {
            if (state is ItemStatusLoading) {
              return LoadingIndicator.inlineDots();
            }
            return Text(status.label.translate(context));
          },
        ),
      ),
    );
  }
}

class _RemoveItemButton extends StatelessWidget {
  const _RemoveItemButton({required this.itemId, required this.isLoading});

  final int itemId;
  final _IsLoadingPredicate isLoading;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteItemCubit, DeleteItemState>(
      listener: (context, state) {
        if (state is DeleteItemSuccess) {
          HelperUtils.showSnackBarMessage(
            context,
            'itemDeletedSuccessfully'.translate(context),
          );
          Navigator.pop(context, true);
        } else if (state is DeleteItemFailure) {
          HelperUtils.showSnackBarMessage(context, state.errorMessage);
        }
      },
      child: AppButton(
        variant: AppButtonVariant.filled,
        onPressed: () async {
          if (isLoading.call()) return;

          final shouldDelete =
              await DeleteAdvertisementDialog.show(context) ?? false;

          if (shouldDelete) {
            context.read<DeleteItemCubit>().deleteItem(id: itemId);
          }
        },
        child: BlocBuilder<DeleteItemCubit, DeleteItemState>(
          builder: (context, state) {
            if (state is DeleteItemLoading) {
              return LoadingIndicator.inlineDots();
            }
            return Text('remove'.translate(context));
          },
        ),
      ),
    );
  }
}

class _SoldOutButton extends StatelessWidget {
  const _SoldOutButton({required this.item, required this.isLoading});

  final MyItem item;
  final _IsLoadingPredicate isLoading;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      variant: AppButtonVariant.filled,
      onPressed: () async {
        if (isLoading.call()) return;

        final didUpdate =
            await Navigator.pushNamed(
                  context,
                  Routes.selectBuyer,
                  arguments: {
                    'preview': item.toPreview(),
                    'is_job_item': item.isJobItem,
                  },
                )
                as bool? ??
            false;

        if (didUpdate) {
          context.read<FetchItemCubit>().fetchItem(
            itemId: item.id,
            isMyAd: true,
          );
        }
      },
      title: item.isJobItem ? 'markAsClosed' : 'soldOut',
    );
  }
}
