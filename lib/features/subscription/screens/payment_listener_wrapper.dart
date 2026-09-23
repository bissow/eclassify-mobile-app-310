import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/subscription/cubits/assign_free_package_cubit.dart';
import 'package:eClassify/features/subscription/cubits/iap_cubit.dart';
import 'package:eClassify/features/subscription/cubits/payment_intent_cubit.dart';
import 'package:eClassify/features/subscription/cubits/payment_methods_cubit.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/core/widgets/surfaces/app_dialog.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/features/subscription/helpers/payment_gateway_registrar.dart';
import 'package:eClassify/features/subscription/helpers/payment_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_core/payment_core.dart';

class PaymentListenerWrapper extends StatelessWidget {
  const PaymentListenerWrapper({
    super.key,
    required this.child,
    required this.package,
    required this.selectedGateway,
  });

  final Widget child;
  final ValueNotifier<SubscriptionPackage?> package;
  final ValueNotifier<PaymentGatewayType?> selectedGateway;

  // ── IAP outcome handlers called by BlocListener ──────────────────────── //

  void _onIapSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AppDialog(
          title: Text(
            'purchaseCompleted'.translate(context),
            style: context.titleLarge,
          ),
          content: Text(
            'purchaseCompletedSuccessfully'.translate(context),
            style: context.bodyMedium,
            textAlign: TextAlign.center,
          ),
          positiveButtonLabel: 'ok'.translate(context),
          onPositiveTapped: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.activePlanScreen,
              (route) => route.isFirst,
            );
          },
        );
      },
    );
  }

  void _onIapError(BuildContext context, String message) {
    HelperUtils.showSnackBarMessage(context, message);
  }

  void _onIapProductNotFound(BuildContext context, String productId) {
    HelperUtils.showSnackBarMessage(
      context,
      'iapProductNotFound'.translate(context),
    );
  }

  void _onIapStoreUnavailable(BuildContext context) {
    HelperUtils.showSnackBarMessage(
      context,
      'iapStoreUnavailable'.translate(context),
    );
  }

  void _onIapCancelled(BuildContext context) {
    HelperUtils.showSnackBarMessage(
      context,
      'purchaseHasBeenCanceled'.translate(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentMethodsCubit, PaymentMethodsState>(
          listener: (context, state) {
            if (state is PaymentMethodsSuccess) {
              PaymentGatewayRegistrar.register(state.gateways);
            }
          },
        ),
        BlocListener<PaymentIntentCubit, PaymentIntentState>(
          listener: (context, state) {
            if (state is PaymentIntentInProgress) {
              LoadingOverlay.show(context);
            } else if (state is PaymentIntentSuccess) {
              LoadingOverlay.hide();
              PaymentHandler.processPayment(
                context: context,
                gatewayType: selectedGateway.value!,
                paymentIntent: state.paymentIntent,
              );
            } else if (state is PaymentIntentFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.error.toString());
            }
          },
        ),
        BlocListener<AssignFreePackageCubit, AssignFreePackageState>(
          listener: (context, state) {
            if (state is AssignFreePackageLoading) {
              LoadingOverlay.show(context);
            }
            if (state is AssignFreePackageSuccess) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.responseMessage);
              Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.activePlanScreen,
                (route) => route.isFirst,
              );
            }
            if (state is AssignFreePackageFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(context, state.error.toString());
            }
          },
        ),
        BlocListener<IapCubit, IapState>(
          listener: (context, state) {
            if (state is IapInProgress) {
              LoadingOverlay.show(context);
            } else {
              LoadingOverlay.hide();
              if (state is IapSuccess) {
                _onIapSuccess(context);
              } else if (state is IapPurchaseError) {
                _onIapError(context, state.message);
              } else if (state is IapProductNotFound) {
                _onIapProductNotFound(context, state.productId);
              } else if (state is IapStoreUnavailable) {
                _onIapStoreUnavailable(context);
              } else if (state is IapPurchaseCancelled) {
                _onIapCancelled(context);
              }
            }
            // IapPurchaseRestored is intentionally ignored — consumables
            // cannot be restored; the state is emitted only for logging.
          },
        ),
      ],
      child: child,
    );
  }
}
