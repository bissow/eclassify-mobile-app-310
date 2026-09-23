import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:eClassify/features/store/repository/store_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class MyStoreState {}

class MyStoreInitial extends MyStoreState {}

class MyStoreLoading extends MyStoreState {}

class MyStoreSuccess extends MyStoreState {
  MyStoreSuccess({required this.store});

  final StoreModel? store;

  bool get hasStore => store != null;
}

class MyStoreFailure extends MyStoreState {
  MyStoreFailure({required this.error});

  final Object error;
}

class MyStoreCubit extends Cubit<MyStoreState> with SessionScoped {
  MyStoreCubit() : super(MyStoreInitial());

  Future<void> fetchMyStore() async {
    try {
      emit(MyStoreLoading());
      final store = await StoreRepository.instance.getMyStore();
      emit(MyStoreSuccess(store: store));
    } on Exception catch (e, stack) {
      Log.error('Error fetching my store: $e', e, stack);
      emit(MyStoreFailure(error: e));
    }
  }

  void updateStore(StoreModel updatedStore) {
    emit(MyStoreSuccess(store: updatedStore));
  }

  Future<bool> toggleStoreStatus() async {
    try {
      final success = await StoreRepository.instance.toggleStoreStatus();
      if (success && state is MyStoreSuccess) {
        final current = (state as MyStoreSuccess).store;
        if (current != null) {
          final newStatus = current.status == 'active' ? 'inactive' : 'active';
          final updated = StoreModel(
            id: current.id,
            userId: current.userId,
            name: current.name,
            slug: current.slug,
            description: current.description,
            logo: current.logo,
            banner: current.banner,
            email: current.email,
            contact: current.contact,
            countryCode: current.countryCode,
            address: current.address,
            latitude: current.latitude,
            longitude: current.longitude,
            city: current.city,
            state: current.state,
            country: current.country,
            areaId: current.areaId,
            areaName: current.areaName,
            website: current.website,
            taxNumber: current.taxNumber,
            openingTime: current.openingTime,
            closingTime: current.closingTime,
            workingDays: current.workingDays,
            isVerified: current.isVerified,
            status: newStatus,
            distance: current.distance,
            stats: current.stats,
            owner: current.owner,
          );
          emit(MyStoreSuccess(store: updated));
        }
      }
      return success;
    } on Exception catch (e, stack) {
      Log.error('Error toggling store status: $e', e, stack);
      return false;
    }
  }

  @override
  void clearSessionState() {
    emit(MyStoreInitial());
  }
}
