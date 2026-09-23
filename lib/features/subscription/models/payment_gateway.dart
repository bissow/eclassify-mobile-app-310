import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/network/api_params.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:payment_core/payment_core.dart';

/// payment_core ships no bankTransfer constant — this is its documented
/// extension pattern (const PaymentGatewayType(id)) for app-defined
/// gateways that have no upstream plugin.
class AppPaymentGatewayType {
  const AppPaymentGatewayType._();

  static const bankTransfer = PaymentGatewayType('bank_transfer');
}

abstract class PaymentGateway {
  const PaymentGateway({required this.type, required this.displayName});

  final PaymentGatewayType type;
  final String displayName;
}

mixin HasApiKey on PaymentGateway {
  String get apiKey;
}

class StripeGateway extends PaymentGateway with HasApiKey {
  const StripeGateway({required this.apiKey})
    : super(type: PaymentGatewayType.stripe, displayName: 'Stripe');

  @override
  final String apiKey;
}

class RazorpayGateway extends PaymentGateway with HasApiKey {
  const RazorpayGateway({required this.apiKey})
    : super(type: PaymentGatewayType.razorpay, displayName: 'Razorpay');

  @override
  final String apiKey;
}

class PhonePeGateway extends PaymentGateway {
  const PhonePeGateway()
    : super(type: PaymentGatewayType.phonepe, displayName: 'PhonePe');
}

class PaystackGateway extends PaymentGateway {
  const PaystackGateway()
    : super(type: PaymentGatewayType.paystack, displayName: 'Paystack');
}

class FlutterwaveGateway extends PaymentGateway {
  const FlutterwaveGateway()
    : super(type: PaymentGatewayType.flutterwave, displayName: 'Flutterwave');
}

class PayPalGateway extends PaymentGateway {
  const PayPalGateway()
    : super(type: PaymentGatewayType.paypal, displayName: 'PayPal');
}

class DpoGateway extends PaymentGateway {
  const DpoGateway() : super(type: PaymentGatewayType.dpo, displayName: 'DPO');
}

class PayTabsGateway extends PaymentGateway {
  const PayTabsGateway()
    : super(type: PaymentGatewayType.paytabs, displayName: 'PayTabs');
}

class BankTransferGateway extends PaymentGateway {
  const BankTransferGateway({required this.details})
    : super(
        type: AppPaymentGatewayType.bankTransfer,
        displayName: 'Bank Transfer',
      );

  final BankTransferDetails details;
}

class BankTransferDetails {
  const BankTransferDetails({
    required this.accountHolderName,
    required this.accountNumber,
    required this.bankName,
    required this.ifscSwiftCode,
  });

  final String accountHolderName;
  final String accountNumber;
  final String bankName;
  final String ifscSwiftCode;

  factory BankTransferDetails.fromJson(Json json) => BankTransferDetails(
    accountHolderName: json[ApiParams.accountHolderName]?.toString() ?? '',
    accountNumber: json[ApiParams.accountNumber]?.toString() ?? '',
    bankName: json[ApiParams.bankName]?.toString() ?? '',
    ifscSwiftCode: json[ApiParams.ifscSwiftCode]?.toString() ?? '',
  );
}

class CashFreeGateway extends PaymentGateway {
  const CashFreeGateway()
    : super(type: PaymentGatewayType.cashfree, displayName: 'CashFree');
}

class PayUGateway extends PaymentGateway {
  const PayUGateway()
    : super(type: PaymentGatewayType.payu, displayName: 'PayU');
}
