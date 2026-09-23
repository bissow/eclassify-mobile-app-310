import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/subscription/cubits/payment_methods_cubit.dart';
import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:payment_core/payment_core.dart';

/// The sole gateway-picker UI, built from the currently enabled gateways
/// held by [PaymentMethodsCubit].
class PaymentMethodSelectorSheet {
  const PaymentMethodSelectorSheet._();

  static Future<PaymentGatewayType?> show(BuildContext context) async {
    final state = context.read<PaymentMethodsCubit>().state;
    final gateways = state is PaymentMethodsSuccess
        ? state.gateways
        : const <PaymentGateway>[];

    if (gateways.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'noPaymentMethodAvailable'.translate(context),
      );
      return null;
    }

    // Only one gateway configured from the panel — nothing to pick between,
    // so skip the sheet and go straight to it.
    if (gateways.length == 1) return gateways.single.type;

    return showModalBottomSheet<PaymentGatewayType>(
      context: context,
      backgroundColor: context.colorScheme.secondary,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: context.bodyPadding(),
          children: [
            Text(
              'selectPaymentMethod'.translate(context),
              style: context.titleMedium.bold,
            ),
            ...gateways.map(
              (gateway) => ListTile(
                leading: CustomImage(
                  src: _iconFor(gateway.type),
                  size: const Size.square(24),
                  fit: BoxFit.scaleDown,
                ),
                title: Text(gateway.displayName),
                onTap: () => Navigator.pop(context, gateway.type),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _iconFor(PaymentGatewayType type) {
    return switch (type) {
      .stripe => AppAssets.payment.stripe,
      .razorpay => AppAssets.payment.razorpay,
      .phonepe => AppAssets.payment.phonePe,
      .paystack => AppAssets.payment.paystack,
      .flutterwave => AppAssets.payment.flutterwave,
      .paypal => AppAssets.payment.paypal,
      .dpo => AppAssets.payment.dpo,
      .paytabs => AppAssets.payment.paytabs,
      .cashfree => AppAssets.payment.cashfree,
      .payu => AppAssets.payment.payu,
      AppPaymentGatewayType.bankTransfer => AppAssets.payment.bankTransfer,
      _ => '',
    };
  }
}
