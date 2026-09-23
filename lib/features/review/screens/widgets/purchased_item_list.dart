import 'package:eClassify/features/review/cubits/purchased_items_cubit.dart';
import 'package:eClassify/features/review/models/purchased_item.dart';
import 'package:eClassify/features/review/screens/widgets/purchased_item_card.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';

class PurchasedItemList extends StatelessWidget {
  const PurchasedItemList({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginatedListView<PurchasedItemsCubit, PurchasedItem, void>(
      padding: context.bodyPadding(),
      itemBuilder: (context, item) => PurchasedItemCard(item: item),
      separatorBuilder: (_, __) => 8.vGap,
    );
  }
}
