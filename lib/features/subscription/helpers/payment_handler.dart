import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/subscription/cubits/payment_methods_cubit.dart';
import 'package:eClassify/features/subscription/helpers/payment_request_generator.dart';
import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:eClassify/features/subscription/repository/payment_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wrteam_payment/wrteam_payment.dart';

class PaymentHandler {
  const PaymentHandler._();

  /// Processes the payment: bank transfer never touches the orchestrator
  /// (there's no client-side gateway step — the payment-intent call is the
  /// action the backend needs), every other gateway builds a request and
  /// hands off to [PaymentOrchestrator].
  static Future<void> processPayment({
    required BuildContext context,
    required PaymentGatewayType gatewayType,
    required Json paymentIntent,
  }) async {
    if (gatewayType == AppPaymentGatewayType.bankTransfer) {
      HelperUtils.showSnackBarMessage(
        context,
        "bankTransferRequestSubmitted".translate(context),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.transactionHistory,
        (route) => route.isFirst,
      );
      return;
    }

    final apiKey = _getApiKey(context, gatewayType);

    try {
      final request = PaymentRequestGenerator.generatePaymentRequest(
        type: gatewayType,
        paymentIntent: paymentIntent,
        apiKey: apiKey,
      );

      final result = await PaymentOrchestrator.pay(context, request);

      if (result.isSuccess || result.isPending) {
        HelperUtils.showSnackBarMessage(
          context,
          (result.isSuccess ? "paymentSuccessfullyCompleted" : "paymentPending")
              .translate(context),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.activePlanScreen,
          (route) => route.isFirst,
        );
      } else if (result.isCancelled) {
        _reportTransactionFailed(paymentIntent);
        HelperUtils.showSnackBarMessage(
          context,
          result.message ?? "subscriptionsCancelled".translate(context),
        );
      } else if (result.isFailed) {
        _reportTransactionFailed(paymentIntent);
        HelperUtils.showSnackBarMessage(
          context,
          result.message ?? "purchaseFailed".translate(context),
        );
      }
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  /// Fire-and-forget: tells the backend the transaction is cancelled so it
  /// doesn't stay stuck in "pending". No UI effect either way.
  static void _reportTransactionFailed(Json paymentIntent) {
    final transactionId = (paymentIntent['payment_transaction_id'] as int?);
    if (transactionId == null) return;

    PaymentRepository.instance
        .makePaymentTransactionFail(paymentTransactionId: transactionId)
        .catchError((e, st) => Log.error(e.toString(), e, st));
  }

  static String? _getApiKey(
    BuildContext context,
    PaymentGatewayType gatewayType,
  ) {
    if (gatewayType != PaymentGatewayType.stripe &&
        gatewayType != PaymentGatewayType.razorpay) {
      return null;
    }

    final gateways =
        (context.read<PaymentMethodsCubit>().state as PaymentMethodsSuccess)
            .gateways;

    for (final gateway in gateways) {
      if (gateway.type == gatewayType && gateway is HasApiKey) {
        return gateway.apiKey;
      }
    }
    return null;
  }
}
