import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:eClassify/features/store/repository/store_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class StoreDetailsState {}

class StoreDetailsInitial extends StoreDetailsState {}

class StoreDetailsLoading extends StoreDetailsState {}

class StoreDetailsSuccess extends StoreDetailsState {
  StoreDetailsSuccess({
    required this.store,
    required this.items,
  });

  final StoreModel store;
  final List<Item> items;
}

class StoreDetailsFailure extends StoreDetailsState {
  StoreDetailsFailure({required this.error});

  final Object error;
}

class StoreDetailsCubit extends Cubit<StoreDetailsState> {
  StoreDetailsCubit() : super(StoreDetailsInitial());

  Future<void> fetchStoreDetails({
    String? slug,
    int? id,
    double? latitude,
    double? longitude,
  }) async {
    try {
      emit(StoreDetailsLoading());
      final result = await StoreRepository.instance.getStoreDetail(
        slug: slug,
        id: id,
        latitude: latitude,
        longitude: longitude,
      );
      emit(StoreDetailsSuccess(store: result.store, items: result.items));
    } on Exception catch (e, stack) {
      Log.error('Error in StoreDetailsCubit: $e', e, stack);
      emit(StoreDetailsFailure(error: e));
    }
  }
}
