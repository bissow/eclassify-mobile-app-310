import 'dart:io';
import 'package:eClassify/features/store/models/seller_qr_model.dart';
import 'package:eClassify/features/store/repository/store_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SellerQrStandeeState {}

class SellerQrStandeeInitial extends SellerQrStandeeState {}

class SellerQrStandeeLoading extends SellerQrStandeeState {}

class SellerQrStandeeLoaded extends SellerQrStandeeState {
  final SellerQrEligibilityModel eligibility;
  final SellerQrCodeModel? qrCode;

  SellerQrStandeeLoaded({
    required this.eligibility,
    this.qrCode,
  });

  SellerQrStandeeLoaded copyWith({
    SellerQrEligibilityModel? eligibility,
    SellerQrCodeModel? qrCode,
  }) {
    return SellerQrStandeeLoaded(
      eligibility: eligibility ?? this.eligibility,
      qrCode: qrCode ?? this.qrCode,
    );
  }
}

class SellerQrStandeeUpdating extends SellerQrStandeeState {
  final SellerQrEligibilityModel eligibility;
  final SellerQrCodeModel? currentQrCode;

  SellerQrStandeeUpdating({
    required this.eligibility,
    this.currentQrCode,
  });
}

class SellerQrStandeeError extends SellerQrStandeeState {
  final String errorMessage;

  SellerQrStandeeError(this.errorMessage);
}

class SellerQrStandeeCubit extends Cubit<SellerQrStandeeState> {
  final StoreRepository _repository;

  SellerQrStandeeCubit({StoreRepository? repository})
      : _repository = repository ?? StoreRepository.instance,
        super(SellerQrStandeeInitial());

  Future<void> loadStandeeData() async {
    emit(SellerQrStandeeLoading());
    try {
      final eligibility = await _repository.checkSellerQrEligibility();
      SellerQrCodeModel? qrCode;

      if (eligibility.isEligible) {
        qrCode = await _repository.getMySellerQr();
      }

      emit(SellerQrStandeeLoaded(
        eligibility: eligibility,
        qrCode: qrCode,
      ));
    } catch (e) {
      emit(SellerQrStandeeError(e.toString()));
    }
  }

  Future<bool> updateStandee({
    String? customSlug,
    String? customTagline,
    String? customColor,
    String? format,
    String? size,
    File? centerLogoFile,
  }) async {
    if (state is! SellerQrStandeeLoaded) return false;
    final current = state as SellerQrStandeeLoaded;

    emit(SellerQrStandeeUpdating(
      eligibility: current.eligibility,
      currentQrCode: current.qrCode,
    ));

    try {
      final updated = await _repository.generateOrUpdateSellerQr(
        customSlug: customSlug,
        customTagline: customTagline,
        customColor: customColor,
        format: format,
        size: size,
        centerLogoFile: centerLogoFile,
      );

      emit(SellerQrStandeeLoaded(
        eligibility: current.eligibility,
        qrCode: updated,
      ));
      return true;
    } catch (e) {
      emit(SellerQrStandeeLoaded(
        eligibility: current.eligibility,
        qrCode: current.qrCode,
      ));
      return false;
    }
  }
}
