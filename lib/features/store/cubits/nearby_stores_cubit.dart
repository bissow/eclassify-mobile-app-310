import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:eClassify/features/store/repository/store_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class NearbyStoresState {}

class NearbyStoresInitial extends NearbyStoresState {}

class NearbyStoresLoading extends NearbyStoresState {}

class NearbyStoresSuccess extends NearbyStoresState {
  NearbyStoresSuccess({
    required this.stores,
    required this.total,
    this.isPageLoading = false,
  });

  final List<StoreModel> stores;
  final int total;
  final bool isPageLoading;

  NearbyStoresSuccess copyWith({
    List<StoreModel>? stores,
    int? total,
    bool? isPageLoading,
  }) {
    return NearbyStoresSuccess(
      stores: stores ?? this.stores,
      total: total ?? this.total,
      isPageLoading: isPageLoading ?? this.isPageLoading,
    );
  }
}

class NearbyStoresFailure extends NearbyStoresState {
  NearbyStoresFailure({required this.error});

  final Object error;
}

class NearbyStoresCubit extends Cubit<NearbyStoresState> {
  NearbyStoresCubit() : super(NearbyStoresInitial());

  int _page = 1;
  bool hasMore = false;

  LeafLocation? _currentLocation;
  num? _radius;
  String? _search;
  String? _sortBy;

  Future<void> fetchStores({
    LeafLocation? location,
    num? radius,
    String? search,
    String? sortBy,
  }) async {
    try {
      emit(NearbyStoresLoading());
      _page = 1;
      _currentLocation = location ?? _currentLocation;
      _radius = radius ?? _radius;
      _search = search;
      _sortBy = sortBy ?? _sortBy;

      final PaginatedResult<StoreModel> result =
          await StoreRepository.instance.getStores(
        latitude: _currentLocation?.latitude,
        longitude: _currentLocation?.longitude,
        radius: _radius ?? _currentLocation?.radius,
        country: _currentLocation?.country?.canonical,
        state: _currentLocation?.state?.canonical,
        city: _currentLocation?.city?.canonical,
        search: _search,
        sortBy: _sortBy,
        page: 1,
      );

      hasMore = result.total > result.data.length;
      emit(NearbyStoresSuccess(stores: result.data, total: result.total));
    } on Exception catch (e, stack) {
      Log.error('Error fetching nearby stores: $e', e, stack);
      emit(NearbyStoresFailure(error: e));
    }
  }

  Future<void> fetchMoreStores() async {
    try {
      if (!hasMore) return;
      if (state case NearbyStoresSuccess(isPageLoading: true)) return;
      if (state is! NearbyStoresSuccess) return;

      final currentState = state as NearbyStoresSuccess;
      emit(currentState.copyWith(isPageLoading: true));

      final nextPage = _page + 1;
      final PaginatedResult<StoreModel> result =
          await StoreRepository.instance.getStores(
        latitude: _currentLocation?.latitude,
        longitude: _currentLocation?.longitude,
        radius: _radius ?? _currentLocation?.radius,
        country: _currentLocation?.country?.canonical,
        state: _currentLocation?.state?.canonical,
        city: _currentLocation?.city?.canonical,
        search: _search,
        sortBy: _sortBy,
        page: nextPage,
      );

      final updatedStores = [...currentState.stores, ...result.data];
      hasMore = result.total > updatedStores.length;
      _page = nextPage;

      emit(
        NearbyStoresSuccess(
          stores: updatedStores,
          total: result.total,
          isPageLoading: false,
        ),
      );
    } on Exception catch (e, stack) {
      Log.error('Error fetching more stores: $e', e, stack);
      if (state is NearbyStoresSuccess) {
        emit((state as NearbyStoresSuccess).copyWith(isPageLoading: false));
      }
    }
  }
}
