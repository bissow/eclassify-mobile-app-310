import 'dart:developer';

import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchItemState {}

class FetchItemInitial extends FetchItemState {}

class FetchItemLoading extends FetchItemState {}

class FetchItemSuccess extends FetchItemState {
  final Item item;

  FetchItemSuccess({required this.item});
}

class FetchItemFailure extends FetchItemState {
  FetchItemFailure({required this.error});

  final Exception error;
}

// TODO(I): Take the parameters in constructor instead of method
class FetchItemCubit extends Cubit<FetchItemState> {
  FetchItemCubit() : super(FetchItemInitial());

  void fetchItem({int? itemId, String? slug, bool isMyAd = false}) {
    assert(
      itemId != null || slug != null,
      'Either itemId or slug should be provided to get the item data',
    );
    if (itemId != null) {
      _fetchItemFromId(id: itemId, isMyAd: isMyAd);
    } else {
      _fetchItemFromSlug(slug: slug!, isMyAd: isMyAd);
    }
  }

  Future<void> _fetchItemFromId({required int id, bool isMyAd = false}) async {
    try {
      emit(FetchItemLoading());

      final item = await ItemRepository.instance.fetchItemFromItemId(
        id,
        isMyAd: isMyAd,
      );
      if (item == null) {
        emit(FetchItemFailure(error: ApiException('Item not found')));
        return;
      }
      emit(FetchItemSuccess(item: item));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'fetchItem');
      log('$stack', name: 'fetchItem');
      emit(FetchItemFailure(error: e));
    }
  }

  Future<void> _fetchItemFromSlug({
    required String slug,
    bool isMyAd = false,
  }) async {
    try {
      emit(FetchItemLoading());

      final item = await ItemRepository.instance.fetchItemFromItemSlug(
        slug,
        isMyAd: isMyAd,
      );
      if (item == null) {
        emit(FetchItemFailure(error: ApiException('Item not found')));
        return;
      }
      emit(FetchItemSuccess(item: item));
    } on Exception catch (e, stack) {
      log(e.toString(), name: 'fetchItemFromSlug');
      log('$stack', name: 'fetchItemFromSlug');
      emit(FetchItemFailure(error: e));
    }
  }
}
