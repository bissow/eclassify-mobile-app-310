import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:payment_core/payment_core.dart';

/// Maps a [PaymentGatewayType] to the backend's expected `payment_method`
/// string for the payment-intent API.
class PaymentGatewayNames {
  const PaymentGatewayNames._();

  static const stripe = 'Stripe';
  static const razorpay = 'Razorpay';
  static const phonePe = 'PhonePe';
  static const paystack = 'Paystack';
  static const flutterwave = 'FlutterWave';
  static const paypal = 'PayPal';
  static const dpo = 'DPO';
  static const paytabs = 'Paytabs';
  static const bankTransfer = 'bankTransfer';
  static const cashfree = 'cashfree-payment-gateway';
  static const payuindia = 'payu-india-payment-gateway';

  static String of(PaymentGatewayType type) {
    return switch (type) {
      .stripe => stripe,
      .razorpay => razorpay,
      .phonepe => phonePe,
      .paystack => paystack,
      .flutterwave => flutterwave,
      .paypal => paypal,
      .dpo => dpo,
      .paytabs => paytabs,
      AppPaymentGatewayType.bankTransfer => bankTransfer,
      .cashfree => cashfree,
      .payu => payuindia,
      _ => throw UnimplementedError('No name for gateway "$type".'),
    };
  }
}
