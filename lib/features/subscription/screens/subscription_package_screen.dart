import 'dart:io';

import 'package:collection/collection.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/tap_guard.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/subscription/cubits/assign_free_package_cubit.dart';
import 'package:eClassify/features/subscription/cubits/iap_cubit.dart';
import 'package:eClassify/features/subscription/cubits/payment_intent_cubit.dart';
import 'package:eClassify/features/subscription/cubits/payment_methods_cubit.dart';
import 'package:eClassify/features/subscription/cubits/subscription_package_cubit.dart';
import 'package:eClassify/features/subscription/helpers/payment_gateway_names.dart';
import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/screens/payment_listener_wrapper.dart';
import 'package:eClassify/features/subscription/screens/widgets/bank_transfer_details_dialog.dart';
import 'package:eClassify/features/subscription/screens/widgets/free_package_purchase_dialog.dart';
import 'package:eClassify/features/subscription/screens/widgets/package_selector.dart';
import 'package:eClassify/features/subscription/screens/widgets/payment_method_selector_sheet.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_core/payment_core.dart';

class SubscriptionPackageScreen extends StatefulWidget {
  const SubscriptionPackageScreen({
    required this.category,
    required this.showCategorySelection,
    this.adItemType,
    this.isRenew = false,
    super.key,
  });

  final Category? category;
  final bool showCategorySelection;

  /// Restricts listing packages to one ad type. Set by the renew flow so a
  /// video-ad item is only offered video-ad packages; null shows all.
  final AdItemType? adItemType;

  /// True when reached from an item's Renew action; sent to get-package as
  /// `is_renew` so the backend can tailor the list.
  final bool isRenew;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SubscriptionPackageCubit()),
          BlocProvider(create: (_) => PaymentMethodsCubit()),
          BlocProvider(create: (_) => PaymentIntentCubit()),
          BlocProvider(create: (_) => AssignFreePackageCubit()),
          // IapCubit is scoped locally here — iOS only, but safe to register
          // on both platforms since buy() is only called when Platform.isIOS.
          BlocProvider(create: (_) => IapCubit()),
        ],
        child: SubscriptionPackageScreen(
          category: args?['category'] as Category?,
          showCategorySelection: args?['show_category_selection'] ?? true,
          adItemType: args?['ad_item_type'] as AdItemType?,
          isRenew: args?['is_renew'] as bool? ?? false,
        ),
      ),
    );
  }

  @override
  State<SubscriptionPackageScreen> createState() =>
      _SubscriptionPackageScreenState();
}

class _SubscriptionPackageScreenState extends State<SubscriptionPackageScreen>
    with WidgetsBindingObserver {
  final ValueNotifier<SubscriptionPackage?> _selectedPackage =
      ValueNotifier<SubscriptionPackage?>(null);

  final ValueNotifier<PaymentGatewayType?> _selectedGateway =
      ValueNotifier<PaymentGatewayType?>(null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    context.read<SubscriptionPackageCubit>().getPackages(
      type: widget.category == null
          ? SubscriptionPackageType.featuredAds
          : SubscriptionPackageType.itemListing,
      categoryId: widget.category?.id,
      adItemType: widget.adItemType,
      isRenew: widget.isRenew,
    );
    if (AppSession.isAuthenticated) {
      context.read<PaymentMethodsCubit>().fetch();
    }
    // Start listening to the App Store purchase stream (iOS only).
    // The cubit owns the subscription; it is cancelled on cubit.close().
    if (Platform.isIOS) {
      context.read<IapCubit>().startListening();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _selectedPackage.dispose();
    _selectedGateway.dispose();
    // IapCubit is closed automatically by BlocProvider when the widget
    // is removed from the tree — no manual dispose needed.
    super.dispose();
  }

  /// StoreKit does not emit a `canceled` event when the payment sheet is
  /// swiped away interactively. Detecting app resume while still in
  /// IapInProgress is the only reliable way to unlock the loading state.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && Platform.isIOS) {
      //context.read<IapCubit>().resetIfStuck();
    }
  }

  final TapGuard _purchaseGuard = TapGuard();

  void _handlePurchase() => _purchaseGuard.run(_purchase);

  Future<void> _purchase() async {
    final package = _selectedPackage.value!;
    if (package.isFree) {
      final shouldPurchase =
          await FreePackagePurchaseDialog.show(context) ?? false;
      if (!shouldPurchase) return;
      context.read<AssignFreePackageCubit>().assignFreePackage(
        packageId: package.id,
      );
    } else if (Platform.isIOS & false) {
      // On iOS, always use App Store IAP regardless of which payment
      // gateways are configured on the backend.
      final productId = package.iosProductId;
      if (productId == null || productId.isEmpty) {
        HelperUtils.showSnackBarMessage(
          context,
          'iapProductNotFound'.translate(context),
        );
        return;
      }
      context.read<IapCubit>().buy(productId: productId, packageId: package.id);
    } else {
      final selectedType = await PaymentMethodSelectorSheet.show(context);

      if (selectedType == null) return;

      // Cashfree rejects orders without a customer phone; fail early with
      // a hint instead of an opaque gateway error.
      if (selectedType == PaymentGatewayType.cashfree &&
          (AppSession.currentUser?.contact.number ?? '').isEmpty) {
        if (!context.mounted) return;
        HelperUtils.showSnackBarMessage(
          context,
          'phoneNumberRequiredForPayment'.translate(context),
        );
        return;
      }

      if (selectedType == AppPaymentGatewayType.bankTransfer) {
        if (!context.mounted) return;
        final methodsState = context.read<PaymentMethodsCubit>().state;
        final bankGateway = methodsState is PaymentMethodsSuccess
            ? methodsState.gateways.whereType<BankTransferGateway>().firstOrNull
            : null;
        if (bankGateway == null) return;

        final confirmed = await BankTransferDetailsDialog.show(
          context,
          details: bankGateway.details,
        );
        if (confirmed != true) return;
      }

      _selectedGateway.value = selectedType;

      if (context.mounted) {
        context.read<PaymentIntentCubit>().getPaymentIntent(
          packageId: package.id,
          paymentMethod: PaymentGatewayNames.of(_selectedGateway.value!),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.category != null
              ? 'adListingPlan'.translate(context)
              : 'featuredAdsPlan'.translate(context),
        ),
        actions: [
          // ======= NOTE ======= //
          // This button was originally added to meet Apple’s iOS subscription guidelines,
          // as apps were being rejected when a Restore Purchases option was missing.
          // It was reintroduced in v2.3.0 for compliance.
          //
          // Recently, however, Apple started rejecting builds because of this button,
          // so it has been temporarily commented out.
          //
          // If Apple requires the Restore Purchases option again,
          // simply uncomment this section to restore it.

          // if (Platform.isIOS)
          //   CupertinoButton(
          //     child: Text("restore".translate(context)),
          //     onPressed: () async {
          //       await InAppPurchase.instance.restorePurchases();
          //     },
          //   ),
        ],
      ),
      bottomNavigationBar:
          BlocBuilder<SubscriptionPackageCubit, SubscriptionPackageState>(
            builder: (context, state) {
              if (state is! SubscriptionPackageSuccess) return const SizedBox();
              return BottomActionBar(
                child: ValueListenableBuilder(
                  valueListenable: _selectedPackage,
                  builder: (context, value, child) {
                    final canPurchase = value != null && value.isPurchasable;
                    return AppButton(
                      variant: AppButtonVariant.filled,
                      onPressed: canPurchase
                          ? () => UiUtils.checkUser(
                              context: context,
                              onNotGuest: () => _handlePurchase(),
                            )
                          : null,
                      child: Text(switch ((value, canPurchase, value?.isFree)) {
                        (_, true, false) =>
                          '${'pay'.translate(context)} ${value!.formattedDiscountedPrice}',
                        (_, _, _) => 'purchase'.translate(context),
                      }),
                    );
                  },
                ),
              );
            },
          ),
      body: PaymentListenerWrapper(
        package: _selectedPackage,
        selectedGateway: _selectedGateway,
        child: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: Column(
            spacing: 20,
            children: [
              if (widget.category != null && widget.showCategorySelection)
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.subscriptionCategorySelectionScreen,
                      (route) =>
                          route.settings.name == Routes.subscriptionScreen ||
                          route.isFirst,
                    );
                  },
                  leading: (widget.category?.image).isNotNullAndNotEmpty
                      ? CustomImage(
                          src: widget.category!.image,
                          size: Size.square(40),
                          radius: 20,
                        )
                      : Icon(
                          AppIcons.globe,
                          color: context.colorScheme.primary,
                        ),
                  title: Text(switch (widget.category?.name.localized) {
                    final value when value.isNotNullAndNotEmpty => value!,
                    _ => 'globalPackage'.translate(context),
                  }, style: context.labelLarge),
                  trailing: IconButton(
                    style: IconButton.styleFrom(
                      disabledForegroundColor: context.colorScheme.onSurface,
                      disabledBackgroundColor: context.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      iconSize: 20,
                    ),
                    onPressed: null,
                    icon: Icon(AppIcons.pencilSimpleLine),
                  ),
                ),
              Expanded(
                child:
                    BlocBuilder<
                      SubscriptionPackageCubit,
                      SubscriptionPackageState
                    >(
                      builder: (context, state) {
                        if (state is SubscriptionPackageLoading) {
                          return Center(child: LoadingIndicator());
                        }
                        if (state is SubscriptionPackageFailure) {
                          return QErrorWidget(
                            error: state.error,
                            onRetry: () {
                              context
                                  .read<SubscriptionPackageCubit>()
                                  .getPackages(
                                    type: widget.category == null
                                        ? SubscriptionPackageType.featuredAds
                                        : SubscriptionPackageType.itemListing,
                                    categoryId: widget.category?.id,
                                    adItemType: widget.adItemType,
                                    isRenew: widget.isRenew,
                                  );
                            },
                          );
                        }
                        if (state is SubscriptionPackageSuccess) {
                          if (state.packages.isEmpty) {
                            return const QErrorWidget.emptyData();
                          }
                          return PackageSelector(
                            packages: state.packages,
                            onSelect: (value) {
                              _selectedPackage.value = value;
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
