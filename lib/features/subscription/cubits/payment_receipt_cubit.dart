import 'package:eClassify/features/subscription/repository/subscription_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PaymentReceiptState {}

class PaymentReceiptInitial extends PaymentReceiptState {}

class PaymentReceiptLoading extends PaymentReceiptState {}

class PaymentReceiptSuccess extends PaymentReceiptState {
  PaymentReceiptSuccess({required this.htmlContent});

  final String htmlContent;
}

class PaymentReceiptFailure extends PaymentReceiptState {
  PaymentReceiptFailure({required this.error});

  final Object error;
}

class PaymentReceiptCubit extends Cubit<PaymentReceiptState> {
  PaymentReceiptCubit() : super(PaymentReceiptInitial());

  Future<void> fetchReceipt(int transactionId) async {
    try {
      emit(PaymentReceiptLoading());
      final response = await SubscriptionRepository.instance.getPaymentReceipt(
        transactionId: transactionId,
      );
      emit(PaymentReceiptSuccess(htmlContent: response));
    } catch (e) {
      emit(PaymentReceiptFailure(error: e));
    }
  }
}
