import 'package:collection/collection.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/subscription/cubits/active_subscription_package_cubit.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PackageSelectBottomSheet {
  static Future<void> show(
    BuildContext context,
    ValueChanged<int?> onSelect, {
    required Category category,
    required AdItemType adItemType,
  }) async {
    final ValueNotifier<SubscriptionPackage?> _selectedPackage = ValueNotifier(
      null,
    );

    return await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      constraints: BoxConstraints(maxHeight: context.screenHeight * 0.85),
      backgroundColor: context.colorScheme.secondary,
      builder: (BuildContext context) {
        return BlocProvider(
          create: (_) => ActiveSubscriptionPackageCubit(),
          child: Padding(
            padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text(
                  'selectPackage'.translate(context),
                  style: context.titleMedium.bold,
                ),
                Expanded(
                  child: _PackageList(
                    category: category,
                    adItemType: adItemType,
                    onSelect: (value) {
                      _selectedPackage.value = value;
                    },
                  ),
                ),
                SafeArea(
                  child:
                      BlocBuilder<
                        ActiveSubscriptionPackageCubit,
                        ActiveSubscriptionPackageState
                      >(
                        builder: (context, state) {
                          if (state is! ActiveSubscriptionPackageSuccess) {
                            return const SizedBox.shrink();
                          }
                          if (state case ActiveSubscriptionPackageSuccess s
                              when s.activePackages.isEmpty) {
                            return AppButton(
                              variant: AppButtonVariant.filled,
                              size: AppButtonSize.small,
                              onPressed: () {
                                Navigator.of(context).popAndPushNamed(
                                  Routes.subscriptionPackageScreen,
                                  arguments: {
                                    'category': category,
                                    'show_category_selection': false,
                                    'ad_item_type': adItemType,
                                    'is_renew': true,
                                  },
                                );
                              },
                              title: 'purchase',
                            );
                          }
                          return ValueListenableBuilder(
                            valueListenable: _selectedPackage,
                            builder: (context, value, child) {
                              return AppButton(
                                variant: AppButtonVariant.filled,
                                size: AppButtonSize.small,
                                onPressed: value == null
                                    ? null
                                    : () {
                                        if (_selectedPackage.value!.isActive) {
                                          onSelect(_selectedPackage.value!.id);
                                          Navigator.of(context).pop();
                                          _selectedPackage.dispose();
                                        } else {
                                          onSelect(null);
                                          HelperUtils.showSnackBarMessage(
                                            context,
                                            'requiredActivePackageWarning'
                                                .translate(context),
                                          );
                                          Navigator.of(context).popAndPushNamed(
                                            Routes.subscriptionPackageScreen,
                                            arguments: {
                                              'category': category,
                                              'show_category_selection': false,
                                              'ad_item_type': adItemType,
                                              'is_renew': true,
                                            },
                                          );
                                        }
                                      },
                                title: 'renewItem',
                              );
                            },
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PackageList extends StatefulWidget {
  const _PackageList({
    required this.onSelect,
    required this.category,
    required this.adItemType,
  });

  final Category category;
  final AdItemType adItemType;
  final ValueChanged<SubscriptionPackage> onSelect;

  @override
  State<_PackageList> createState() => _PackageListState();
}

class _PackageListState extends State<_PackageList> {
  SubscriptionPackage? _selectedPackage;

  @override
  void initState() {
    super.initState();
    context.read<ActiveSubscriptionPackageCubit>().getPackages(
      type: SubscriptionPackageType.itemListing,
      categoryId: widget.category.id,
      adItemType: widget.adItemType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      ActiveSubscriptionPackageCubit,
      ActiveSubscriptionPackageState
    >(
      builder: (context, state) {
        if (state is ActiveSubscriptionPackageLoading) {
          return Center(child: LoadingIndicator());
        }
        if (state is ActiveSubscriptionPackageFailure) {
          return QErrorWidget(
            error: state.error,
            onRetry: () {
              context.read<ActiveSubscriptionPackageCubit>().getPackages(
                type: SubscriptionPackageType.itemListing,
                categoryId: widget.category.id,
                adItemType: widget.adItemType,
              );
            },
          );
        }
        if (state is ActiveSubscriptionPackageSuccess) {
          if (state.activePackages.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 10,
              children: [
                Text(
                  'subscriptionRequired'.translate(context),
                  style: context.titleMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  // Only opened from the renew action today; the copy names
                  // the ad type (regular / video ad) so a video-ad item
                  // isn't told to buy any listing package.
                  'renewItemSubscriptionNotice'.translate(context, {
                    'category_name': widget.category.name.localized,
                    'ad_type': widget.adItemType.label.translate(context),
                  }),
                  textAlign: TextAlign.center,
                  style: context.titleSmall,
                ),
              ],
            );
          }

          final packages = groupBy(
            state.activePackages,
            (element) => element.isGlobal,
          );
          final globalPackages = packages[true] ?? [];
          final categoryPackages = packages[false] ?? [];

          return Material(
            color: Colors.transparent,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  if (categoryPackages.isNotEmpty) ...[
                    Text(
                      '${'category'.translate(context)}: ${widget.category.name.localized}',
                      style: context.titleMedium,
                    ),
                    ...List.generate(categoryPackages.length, (index) {
                      return _PackageItem(
                        key: ValueKey(categoryPackages[index].id),
                        package: categoryPackages[index],
                        isSelected: categoryPackages[index] == _selectedPackage,
                        onSelect: (package) {
                          _selectedPackage = package;
                          setState(() {});
                          widget.onSelect(package);
                        },
                      );
                    }),
                  ],
                  if (globalPackages.isNotEmpty) ...[
                    Text(
                      'globalPackage'.translate(context),
                      style: context.titleMedium,
                    ),
                    ...List.generate(globalPackages.length, (index) {
                      return _PackageItem(
                        key: ValueKey(globalPackages[index].id),
                        package: globalPackages[index],
                        isSelected: globalPackages[index] == _selectedPackage,
                        onSelect: (package) {
                          _selectedPackage = package;
                          setState(() {});
                          widget.onSelect(package);
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _PackageItem extends StatelessWidget {
  const _PackageItem({
    required this.package,
    required this.isSelected,
    required this.onSelect,
    super.key,
  });

  final SubscriptionPackage package;
  final bool isSelected;
  final ValueChanged<SubscriptionPackage> onSelect;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onSelect(package),
      selected: isSelected,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? context.colorScheme.primary : context.mutedColor,
        ),
      ),
      titleTextStyle: context.titleSmall.bold,
      title: Text(package.name.localized),
      subtitle: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  '${package.hasUnlimitedItem ? 'unlimited'.translate(context) : package.itemLimit} ${'ads'.translate(context)}',
              style: context.bodySmall,
            ),
            const TextSpan(text: '\t'),
            TextSpan(
              text:
                  '${package.hasUnlimitedDuration ? 'unlimited'.translate(context) : package.listingDurationDays} ${'days'.translate(context)}',
              style: context.bodySmall.withColor(context.mutedColor),
            ),
          ],
        ),
      ),
    );
  }
}
