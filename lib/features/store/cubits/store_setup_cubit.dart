import 'dart:io';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:eClassify/features/store/repository/store_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StoreSetupState {}

class StoreSetupInitial extends StoreSetupState {}

class StoreSetupLoading extends StoreSetupState {}

class StoreSetupSuccess extends StoreSetupState {
  StoreSetupSuccess({required this.store});

  final StoreModel store;
}

class StoreSetupFailure extends StoreSetupState {
  StoreSetupFailure({required this.error});

  final Object error;
}

class StoreSetupCubit extends Cubit<StoreSetupState> {
  StoreSetupCubit() : super(StoreSetupInitial());

  Future<void> saveStore({
    required Map<String, dynamic> fields,
    File? logoFile,
    File? bannerFile,
  }) async {
    try {
      emit(StoreSetupLoading());
      final store = await StoreRepository.instance.setupStore(
        fields: fields,
        logoFile: logoFile,
        bannerFile: bannerFile,
      );
      emit(StoreSetupSuccess(store: store));
    } on Exception catch (e, stack) {
      Log.error('Error saving store: $e', e, stack);
      emit(StoreSetupFailure(error: e));
    }
  }
}
