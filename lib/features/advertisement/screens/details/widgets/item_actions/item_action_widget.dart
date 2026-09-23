import 'package:eClassify/features/advertisement/cubits/fetch_item_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/item_status_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/renew_item_cubit.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_actions/buyer_item_actions.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_actions/seller_item_actions.dart';
import 'package:eClassify/features/item/extensions/item_extension.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemActionWidget extends StatefulWidget {
  const ItemActionWidget({super.key});

  @override
  State<ItemActionWidget> createState() => _ItemActionWidgetState();
}

class _ItemActionWidgetState extends State<ItemActionWidget> {
  Item? _lastItem;

  @override
  Widget build(BuildContext context) {
    final item = context.select<FetchItemCubit, Item?>(
      (cubit) => switch (cubit.state) {
        FetchItemSuccess(item: final item) => item,
        _ => null,
      },
    );

    if (item != null) _lastItem = item;

    final displayItem = _lastItem;
    if (displayItem == null) return const SizedBox.shrink();

    return BottomActionBar(
      child: (displayItem.isMyAd && displayItem is MyItem)
          ? MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => RenewItemCubit()),
                BlocProvider(create: (_) => ItemStatusCubit()),
              ],
              child: SellerItemActions(item: displayItem),
            )
          : BuyerItemAction(item: displayItem),
    );
  }
}
