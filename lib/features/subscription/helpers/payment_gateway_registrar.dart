import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:wrteam_payment/wrteam_payment.dart';

/// Registers a [PaymentGatewayPlugin] for every currently-enabled gateway.
/// Only enabled gateways get a plugin — the registry itself enforces which
/// gateways are payable, not just the picker UI.
class PaymentGatewayRegistrar {
  const PaymentGatewayRegistrar._();

  static void register(List<PaymentGateway> gateways) {
    PaymentRegistry.clear();
    for (final gateway in gateways) {
      final plugin = _buildPlugin(gateway);
      if (plugin != null) PaymentRegistry.register(plugin);
    }
  }

  static PaymentGatewayPlugin? _buildPlugin(PaymentGateway gateway) {
    return switch (gateway) {
      StripeGateway() => StripeGatewayPlugin(),
      RazorpayGateway() => RazorpayGatewayPlugin(),
      PhonePeGateway() => PhonePeGatewayPlugin(),
      PaystackGateway() => PaystackGatewayPlugin(),
      FlutterwaveGateway() => FlutterwaveGatewayPlugin(),
      PayPalGateway() => PayPalGatewayPlugin(),
      DpoGateway() => DpoGatewayPlugin(),
      PayTabsGateway() => PayTabsGatewayPlugin(),
      CashFreeGateway() => CashfreeGatewayPlugin(),
      PayUGateway() => PayUGatewayPlugin(),
      // BankTransferGateway has no plugin — handled directly in PaymentHandler.
      _ => null,
    };
  }
}
