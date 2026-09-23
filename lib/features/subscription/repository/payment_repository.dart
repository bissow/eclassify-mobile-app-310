import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/subscription/helpers/payment_gateway_names.dart';
import 'package:eClassify/features/subscription/models/payment_gateway.dart';

class PaymentRepository {
  PaymentRepository._internal();

  static final PaymentRepository _instance = PaymentRepository._internal();

  static PaymentRepository get instance => _instance;

  /// Fetches the payment gateways enabled by the backend. The API only
  /// returns entries for enabled gateways, so presence in the response is
  /// itself the "enabled" signal — no separate status filtering needed.
  Future<List<PaymentGateway>> getPaymentGateways() async {
    final result = await Api.get(url: ApiEndpoints.getPaymentSettings);
    final data = (result['data'] ?? {}) as Json;

    Log.info('${data}');

    return data.entries
        .map((entry) => _gatewayFromEntry(entry.key, entry.value as Json))
        .whereType<PaymentGateway>()
        .toList();
  }

  PaymentGateway? _gatewayFromEntry(String key, Json value) {
    return switch (key) {
      PaymentGatewayNames.stripe => StripeGateway(
        apiKey: value[ApiParams.apiKey]?.toString() ?? '',
      ),
      PaymentGatewayNames.razorpay => RazorpayGateway(
        apiKey: value[ApiParams.apiKey]?.toString() ?? '',
      ),
      PaymentGatewayNames.phonePe => const PhonePeGateway(),
      PaymentGatewayNames.paystack => const PaystackGateway(),
      PaymentGatewayNames.flutterwave => const FlutterwaveGateway(),
      PaymentGatewayNames.paypal => const PayPalGateway(),
      PaymentGatewayNames.dpo => const DpoGateway(),
      PaymentGatewayNames.paytabs => const PayTabsGateway(),
      PaymentGatewayNames.bankTransfer => BankTransferGateway(
        details: BankTransferDetails.fromJson(value),
      ),
      PaymentGatewayNames.cashfree => const CashFreeGateway(),
      PaymentGatewayNames.payuindia => const PayUGateway(),
      _ => null,
    };
  }

  Future<Json> getPaymentIntent({
    required int packageId,
    required String paymentMethod,
  }) async {
    final response = await Api.post(
      url: ApiEndpoints.getPaymentIntent,
      parameter: {
        ApiParams.packageId: packageId,
        ApiParams.paymentMethod: paymentMethod,
        if (paymentMethod case == "Paystack" || "PhonePe" || "PayPal")
          ApiParams.platformType: "app",
      },
    );
    return response;
  }

  Future<void> makePaymentTransactionFail({
    required int paymentTransactionId,
  }) async {
    await Api.post(
      url: ApiEndpoints.makePaymentTransactionFail,
      parameter: {ApiParams.paymentTransactionId: paymentTransactionId},
    );
  }
}
