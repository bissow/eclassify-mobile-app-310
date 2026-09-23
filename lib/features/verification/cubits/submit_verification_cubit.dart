import 'package:eClassify/features/custom_fields/models/custom_field_value.dart';
import 'package:eClassify/features/verification/repository/verification_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubmitVerificationState {}

class SubmitVerificationInitial extends SubmitVerificationState {}

class SubmitVerificationLoading extends SubmitVerificationState {}

class SubmitVerificationSuccess extends SubmitVerificationState {
  SubmitVerificationSuccess({required this.message});

  final String message;
}

class SubmitVerificationFailure extends SubmitVerificationState {
  SubmitVerificationFailure(this.errorMessage);

  final String errorMessage;
}

class SubmitVerificationCubit extends Cubit<SubmitVerificationState> {
  SubmitVerificationCubit() : super(SubmitVerificationInitial());

  void submit({required Map<int, CustomFieldValue> data}) async {
    try {
      emit(SubmitVerificationLoading());

      final response = await UserVerificationRepository.instance
          .submitVerificationDetails(data: data);

      emit(SubmitVerificationSuccess(message: response));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(SubmitVerificationFailure(e.toString()));
    }
  }
}
