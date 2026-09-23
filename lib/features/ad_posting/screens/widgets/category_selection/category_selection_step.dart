import 'package:eClassify/features/custom_fields/cubits/custom_fields_cubit.dart';
import 'package:eClassify/features/ad_posting/cubits/ad_posting_cubit.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/category/screens/category_config_scope.dart';
import 'package:eClassify/features/category/screens/category_picker.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/features/subscription/screens/widgets/no_package_available_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategorySelectionStep extends StatelessWidget {
  const CategorySelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    final adType = context.read<AdPostingCubit>().state.adPostingData.adType;
    return Padding(
      padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
      child: CategoryConfigScope(
        isDisabled: (category) {
          return adType == AdItemType.regularAd
              ? !category.canPostRegularAds
              : !category.canPostVideoAds;
        },
        onDisabledTap: (category) {
          NoPackageAvailableDialog.show(
            context,
            type: SubscriptionPackageType.itemListing,
            adType: adType ?? AdItemType.regularAd,
            category: category,
          );
        },
        child: CategoryPicker(
          showAllOption: false,
          showBreadcrumbs: false,
          resetSelection: false,
          onSelect: (category, hierarchy) {
            context.read<CustomFieldsCubit>().getCustomFields(
              categoryId: category.id,
            );
            context.read<AdPostingCubit>()
              ..updateData((current) => current.copyWith(category: category))
              ..nextStep();
          },
        ),
      ),
    );
  }
}
