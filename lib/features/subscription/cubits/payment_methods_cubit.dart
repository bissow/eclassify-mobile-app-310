import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/subscription/models/payment_gateway.dart';
import 'package:eClassify/features/subscription/repository/payment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class PaymentMethodsState {}

class PaymentMethodsInitial extends PaymentMethodsState {}

class PaymentMethodsLoading extends PaymentMethodsState {}

class PaymentMethodsFailure extends PaymentMethodsState {
  PaymentMethodsFailure(this.error);

  final String error;
}

class PaymentMethodsSuccess extends PaymentMethodsState {
  PaymentMethodsSuccess(this.gateways);

  final List<PaymentGateway> gateways;
}

/// Cubit responsible for fetching and holding the currently enabled
/// payment gateways.
class PaymentMethodsCubit extends Cubit<PaymentMethodsState> {
  PaymentMethodsCubit() : super(PaymentMethodsInitial());

  Future<void> fetch() async {
    try {
      emit(PaymentMethodsLoading());
      final gateways = await PaymentRepository.instance.getPaymentGateways();
      Log.info('$gateways');
      emit(PaymentMethodsSuccess(gateways));
    } catch (e) {
      emit(PaymentMethodsFailure(e.toString()));
    }
  }
}
