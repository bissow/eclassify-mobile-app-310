import 'dart:io';
import 'package:eClassify/features/subscription/repository/subscription_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BankTransferReceiptState {}

class BankTransferReceiptInitial extends BankTransferReceiptState {}

class BankTransferReceiptUploading extends BankTransferReceiptState {}

class BankTransferReceiptSuccess extends BankTransferReceiptState {
  BankTransferReceiptSuccess({
    required this.responseMessage,
    required this.transactionId,
  });

  final String responseMessage;
  final int transactionId;
}

class BankTransferReceiptFailure extends BankTransferReceiptState {
  BankTransferReceiptFailure({required this.errorMessage});

  final String errorMessage;
}

class BankTransferReceiptCubit extends Cubit<BankTransferReceiptState> {
  BankTransferReceiptCubit() : super(BankTransferReceiptInitial());

  void uploadReceipt({
    required int transactionId,
    required File receipt,
  }) async {
    try {
      emit(BankTransferReceiptUploading());

      final response = await SubscriptionRepository.instance
          .uploadBankTransferReceipt(
            transactionId: transactionId,
            receipt: receipt,
          );

      emit(
        BankTransferReceiptSuccess(
          responseMessage: response,
          transactionId: transactionId,
        ),
      );
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(BankTransferReceiptFailure(errorMessage: e.toString()));
    }
  }
}
