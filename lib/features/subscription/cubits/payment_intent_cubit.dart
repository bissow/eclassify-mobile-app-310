import 'package:eClassify/features/subscription/repository/payment_repository.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PaymentIntentState {}

class PaymentIntentInitial extends PaymentIntentState {}

class PaymentIntentInProgress extends PaymentIntentState {}

class PaymentIntentSuccess extends PaymentIntentState {
  PaymentIntentSuccess({required this.paymentIntent});

  final Json paymentIntent;
}

class PaymentIntentFailure extends PaymentIntentState {
  PaymentIntentFailure({required this.error});

  final String error;
}

class PaymentIntentCubit extends Cubit<PaymentIntentState> {
  PaymentIntentCubit() : super(PaymentIntentInitial());

  final PaymentRepository repository = PaymentRepository.instance;

  void getPaymentIntent({
    required int packageId,
    required String paymentMethod,
  }) async {
    try {
      emit(PaymentIntentInProgress());

      final intent = await repository.getPaymentIntent(
        packageId: packageId,
        paymentMethod: paymentMethod,
      );

      emit(
        PaymentIntentSuccess(
          paymentIntent: intent['data']['payment_intent'] as Json? ?? {},
        ),
      );
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(PaymentIntentFailure(error: e.toString()));
    }
  }
}
