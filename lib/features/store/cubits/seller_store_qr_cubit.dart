import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/store/models/seller_qr_model.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:eClassify/features/store/repository/store_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

abstract class SellerStoreQrState {}

class SellerStoreQrInitial extends SellerStoreQrState {}

class SellerStoreQrLoading extends SellerStoreQrState {}

class SellerStoreQrSuccess extends SellerStoreQrState {
  final StoreModel store;
  final List<ItemPreview> items;
  final LocationWarningModel locationWarning;
  final List<Map<String, dynamic>> categories;
  final int total;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;
  final SellerQrCodeModel? qrCode;

  SellerStoreQrSuccess({
    required this.store,
    required this.items,
    required this.locationWarning,
    required this.categories,
    required this.total,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.qrCode,
  });

  SellerStoreQrSuccess copyWith({
    StoreModel? store,
    List<ItemPreview>? items,
    LocationWarningModel? locationWarning,
    List<Map<String, dynamic>>? categories,
    int? total,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
    SellerQrCodeModel? qrCode,
  }) {
    return SellerStoreQrSuccess(
      store: store ?? this.store,
      items: items ?? this.items,
      locationWarning: locationWarning ?? this.locationWarning,
      categories: categories ?? this.categories,
      total: total ?? this.total,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}

class SellerStoreQrFailure extends SellerStoreQrState {
  final String errorMessage;

  SellerStoreQrFailure(this.errorMessage);
}

class SellerStoreQrCubit extends Cubit<SellerStoreQrState> {
  final StoreRepository _repository;

  SellerStoreQrCubit({StoreRepository? repository})
      : _repository = repository ?? StoreRepository.instance,
        super(SellerStoreQrInitial());

  String? _lastIdentifier;
  double? _userLat;
  double? _userLng;
  String? _search;
  int? _categoryId;
  String? _sortBy;

  Future<void> fetchStoreCatalog({
    required String identifier,
    double? latitude,
    double? longitude,
    String? search,
    int? categoryId,
    String? sortBy,
  }) async {
    _lastIdentifier = identifier;
    _search = search;
    _categoryId = categoryId;
    _sortBy = sortBy;

    emit(SellerStoreQrLoading());

    // Try obtaining user's GPS coordinates if not passed
    if (latitude != null && longitude != null) {
      _userLat = latitude;
      _userLng = longitude;
    } else if (_userLat == null) {
      try {
        final permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse) {
          final pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.low,
              timeLimit: Duration(seconds: 4),
            ),
          );
          _userLat = pos.latitude;
          _userLng = pos.longitude;
        }
      } catch (e) {
        Log.warning('Could not get GPS for QR scan mismatch check: $e');
      }
    }


    try {
      final res = await _repository.getStoreByQr(
        identifier: identifier,
        latitude: _userLat,
        longitude: _userLng,
        search: _search,
        categoryId: _categoryId,
        sortBy: _sortBy,
        page: 1,
        limit: 16,
      );

      final hasMore = res.items.length < res.total;

      emit(SellerStoreQrSuccess(
        store: res.store,
        items: res.items,
        locationWarning: res.locationWarning,
        categories: res.categories,
        total: res.total,
        currentPage: 1,
        hasMore: hasMore,
        qrCode: res.qrCode,
      ));
    } catch (e) {
      emit(SellerStoreQrFailure(e.toString()));
    }
  }

  Future<void> loadMore() async {
    if (state is! SellerStoreQrSuccess) return;
    final currentState = state as SellerStoreQrSuccess;
    if (!currentState.hasMore || currentState.isLoadingMore || _lastIdentifier == null) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    try {
      final res = await _repository.getStoreByQr(
        identifier: _lastIdentifier!,
        latitude: _userLat,
        longitude: _userLng,
        search: _search,
        categoryId: _categoryId,
        sortBy: _sortBy,
        page: nextPage,
        limit: 16,
      );

      final updatedItems = List<ItemPreview>.from(currentState.items)..addAll(res.items);
      final hasMore = updatedItems.length < res.total;

      emit(currentState.copyWith(
        items: updatedItems,
        currentPage: nextPage,
        hasMore: hasMore,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }
}
