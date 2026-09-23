import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class RelatedItemsState {}

class RelatedItemsInitial extends RelatedItemsState {}

class RelatedItemsLoading extends RelatedItemsState {}

class RelatedItemsSuccess extends RelatedItemsState {
  RelatedItemsSuccess({required this.items});

  final List<ItemPreview> items;
}

class RelatedItemsFailure extends RelatedItemsState {}

class RelatedItemsCubit extends Cubit<RelatedItemsState> {
  RelatedItemsCubit() : super(RelatedItemsInitial());

  Future<void> fetchRelatedItems({
    required int categoryId,
    required LeafLocation? location,
    required int excludedItemId,
  }) async {
    try {
      emit(RelatedItemsLoading());

      final items = await ItemRepository.instance.fetchItemFromCatId(
        categoryId: categoryId,
        location: location,
        excludedItemId: excludedItemId,
      );

      emit(RelatedItemsSuccess(items: items));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(RelatedItemsFailure());
    }
  }
}
