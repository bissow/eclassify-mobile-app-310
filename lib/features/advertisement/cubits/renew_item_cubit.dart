import 'dart:developer';

import 'package:eClassify/features/advertisement/repository/renew_item_repository.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RenewItemState {}

class RenewItemInitial extends RenewItemState {}

class RenewItemLoading extends RenewItemState {}

class RenewItemSuccess extends RenewItemState {
  RenewItemSuccess({required this.responseMessage});

  final String responseMessage;
}

class RenewItemFailure extends RenewItemState {
  RenewItemFailure({required this.errorMessage});

  final String errorMessage;
}

class RenewItemCubit extends Cubit<RenewItemState> {
  RenewItemCubit() : super(RenewItemInitial());
  RenewItemRepository repository = RenewItemRepository();

  void renewItem({required int itemId, int? packageId}) async {
    try {
      emit(RenewItemLoading());

      final response = await repository.renewItem(
        itemId: itemId,
        packageId: packageId,
      );

      emit(RenewItemSuccess(responseMessage: response));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(RenewItemFailure(errorMessage: e.toString()));
    }
  }

  Future<void> renewMultiItems({
    required Iterable<int> ids,
    int? packageId,
  }) async {
    try {
      emit(RenewItemLoading());

      final response = await repository.renewItem(
        itemIds: ids,
        packageId: packageId,
      );

      emit(RenewItemSuccess(responseMessage: response));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'renewMultiItems');
      log('$stack', name: 'renewMultiItems');
      throw ApiException(e.toString());
    }
  }
}
