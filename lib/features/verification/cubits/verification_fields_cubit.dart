import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/verification/repository/verification_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class VerificationFieldsState {}

class VerificationFieldsInitial extends VerificationFieldsState {}

class VerificationFieldsLoading extends VerificationFieldsState {}

class VerificationFieldsSuccess extends VerificationFieldsState {
  VerificationFieldsSuccess({required this.fields});

  final List<CustomField> fields;
}

class VerificationFieldsFailure extends VerificationFieldsState {
  VerificationFieldsFailure({required this.error});

  final Object error;
}

class VerificationFieldsCubit extends Cubit<VerificationFieldsState> {
  VerificationFieldsCubit() : super(VerificationFieldsInitial());

  void getUserVerificationFields() async {
    try {
      emit(VerificationFieldsLoading());
      final fields = await UserVerificationRepository.instance
          .getUserVerificationFields();

      emit(VerificationFieldsSuccess(fields: fields));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(VerificationFieldsFailure(error: e));
    }
  }
}
