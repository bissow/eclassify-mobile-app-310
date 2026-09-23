import 'dart:developer';

import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteItemState {}

class DeleteItemInitial extends DeleteItemState {}

class DeleteItemLoading extends DeleteItemState {}

class DeleteItemSuccess extends DeleteItemState {
  DeleteItemSuccess([this.deletedIds = const <int>{}]);

  final Set<int> deletedIds;
}

class DeleteItemFailure extends DeleteItemState {
  final String errorMessage;

  DeleteItemFailure(this.errorMessage);
}

class DeleteItemCubit extends Cubit<DeleteItemState> {
  DeleteItemCubit() : super(DeleteItemInitial());
  final ItemRepository _itemRepository = ItemRepository.instance;

  Future<void> deleteItem({required int id}) async {
    try {
      emit(DeleteItemLoading());

      await _itemRepository.deleteItem(id: id);
      emit(DeleteItemSuccess({id}));
    } catch (e) {
      emit(DeleteItemFailure(e.toString()));
    }
  }

  Future<void> deleteMultiItem({required Iterable<int> ids}) async {
    try {
      emit(DeleteItemLoading());

      await _itemRepository.deleteItem(ids: ids);
      emit(DeleteItemSuccess(ids.toSet()));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'deleteMultiItem');
      log('$stack', name: 'deleteMultiItem');
      throw ApiException(e.toString());
    }
  }
}
