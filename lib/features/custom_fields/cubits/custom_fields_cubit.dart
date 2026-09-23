import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/custom_fields/repository/custom_fields_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CustomFieldsState {}

class CustomFieldsInitial extends CustomFieldsState {}

class CustomFieldsLoading extends CustomFieldsState {}

class CustomFieldsSuccess extends CustomFieldsState {
  CustomFieldsSuccess({required this.fields});

  final List<CustomField> fields;
}

class CustomFieldsFailure extends CustomFieldsState {
  CustomFieldsFailure({required this.message});

  final String message;
}

class CustomFieldsCubit extends Cubit<CustomFieldsState> {
  CustomFieldsCubit() : super(CustomFieldsInitial());

  Future<void> getCustomFields({
    required int categoryId,
    bool isForFilter = false,
  }) async {
    try {
      emit(CustomFieldsLoading());

      final fields = await CustomFieldsRepository.instance.getCustomFields(
        categoryId: categoryId,
        isForFilter: isForFilter,
      );

      emit(CustomFieldsSuccess(fields: fields));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(CustomFieldsFailure(message: e.toString()));
    }
  }
}
