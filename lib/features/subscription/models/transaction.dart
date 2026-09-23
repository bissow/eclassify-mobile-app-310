import 'package:eClassify/core/utils/json_helper.dart';
import 'package:flutter/material.dart';

enum PaymentStatus {
  failed('failed', Colors.red),
  succeed('succeed', Colors.green),
  pending('pending', Colors.amber);

  const PaymentStatus(this.label, this.color);

  final String label;
  final Color color;

  static PaymentStatus fromString(String value) =>
      PaymentStatus.values.firstWhere(
        (element) => element.name == value,
        orElse: () => PaymentStatus.pending,
      );
}

class Transaction {
  Transaction({
    required this.id,
    required this.orderId,
    required this.packageId,
    required this.amount,
    required this.formattedAmount,
    required this.paymentGateway,
    required this.status,
    required this.date,
    this.hasUploadedReceipt = false,
  });

  Transaction.fromJson(Json json)
    : id = json['id'] as int,
      orderId = json['order_id'] as String,
      packageId = json['package_id'] as int,
      amount = json['amount'] as num,
      formattedAmount = json['formatted_amount'] as String,
      paymentGateway = json['payment_gateway'] as String,
      status = PaymentStatus.fromString(json['payment_status'] as String),
      date = DateTime.parse(json['created_at'] as String),
      hasUploadedReceipt = json['payment_receipt'] != null;

  final int id;
  final String orderId;
  final int packageId;
  final num amount;
  final String formattedAmount;
  final String paymentGateway;
  final PaymentStatus status;
  final DateTime date;
  final bool hasUploadedReceipt;

  bool get isBankTransfer => paymentGateway.toLowerCase() == 'banktransfer';

  Transaction copyWith({required bool hasUploadedReceipt}) => Transaction(
    id: id,
    orderId: orderId,
    packageId: packageId,
    amount: amount,
    formattedAmount: formattedAmount,
    paymentGateway: paymentGateway,
    status: status,
    date: date,
    hasUploadedReceipt: hasUploadedReceipt,
  );
}
