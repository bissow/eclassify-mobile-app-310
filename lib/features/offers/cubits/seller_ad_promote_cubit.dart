import 'package:eClassify/features/offers/models/ad_promotion_options_model.dart';
import 'package:eClassify/features/offers/models/promotion_model.dart';
import 'package:eClassify/features/offers/repository/offers_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SellerAdPromoteState {}

class SellerAdPromoteInitial extends SellerAdPromoteState {}

class SellerAdPromoteLoading extends SellerAdPromoteState {}

class SellerAdPromoteOptionsSuccess extends SellerAdPromoteState {
  final AdPromotionOptionsModel options;
  SellerAdPromoteOptionsSuccess(this.options);
}

class SellerAvailablePromotionsSuccess extends SellerAdPromoteState {
  final List<PromotionModel> promotions;
  final bool isVerified;
  final String? verificationStatus;
  final bool requiresVerification;
  final bool requiresPackage;
  final String? eligibilityMsg;
  final String remainingQuota;

  final List<int> alreadySubmittedPromotionIds;

  SellerAvailablePromotionsSuccess({
    required this.promotions,
    this.isVerified = true,
    this.verificationStatus,
    this.requiresVerification = false,
    this.requiresPackage = false,
    this.eligibilityMsg,
    this.remainingQuota = 'unlimited',
    this.alreadySubmittedPromotionIds = const [],
  });
}

class SellerAdPromoteActionSuccess extends SellerAdPromoteState {
  final String message;
  SellerAdPromoteActionSuccess(this.message);
}

class SellerAdPromoteFailure extends SellerAdPromoteState {
  final String errorMessage;
  SellerAdPromoteFailure(this.errorMessage);
}

class SellerAdPromoteCubit extends Cubit<SellerAdPromoteState> {
  SellerAdPromoteCubit({OffersRepository? repository})
      : _repository = repository ?? OffersRepository(),
        super(SellerAdPromoteInitial());

  final OffersRepository _repository;

  Future<void> fetchPromotionOptions(int itemId) async {
    try {
      emit(SellerAdPromoteLoading());
      final options = await _repository.getAdPromotionOptions(itemId);
      emit(SellerAdPromoteOptionsSuccess(options));
    } catch (e) {
      emit(SellerAdPromoteFailure(e.toString()));
    }
  }

  Future<void> fetchAvailablePromotions({int? itemId}) async {
    try {
      emit(SellerAdPromoteLoading());
      final data = await _repository.getAvailablePromotionsData(itemId: itemId);
      emit(SellerAvailablePromotionsSuccess(
        promotions: (data['promotions'] as List<PromotionModel>?) ?? [],
        isVerified: data['is_verified'] as bool? ?? true,
        verificationStatus: data['verification_status'] as String?,
        requiresVerification: data['requires_verification'] as bool? ?? false,
        requiresPackage: data['requires_package'] as bool? ?? false,
        eligibilityMsg: data['eligibility_msg'] as String?,
        remainingQuota: data['remaining_quota'] as String? ?? 'unlimited',
        alreadySubmittedPromotionIds: (data['already_submitted_promotion_ids'] as List<int>?) ?? [],
      ));
    } catch (e) {
      emit(SellerAdPromoteFailure(e.toString()));
    }
  }

  Future<void> promoteAd({
    required int itemId,
    required String promotionType,
    required int durationDays,
  }) async {
    try {
      emit(SellerAdPromoteLoading());
      final res = await _repository.promoteAd(
        itemId: itemId,
        promotionType: promotionType,
        durationDays: durationDays,
      );
      if (res['error'] == false) {
        emit(SellerAdPromoteActionSuccess(res['message'] ?? 'Ad promoted successfully!'));
      } else {
        emit(SellerAdPromoteFailure(res['message'] ?? 'Failed to promote ad'));
      }
    } catch (e) {
      emit(SellerAdPromoteFailure(e.toString()));
    }
  }

  Future<void> joinPromotion({
    required int promotionId,
    required int itemId,
    required String discountType,
    required double discountValue,
    required int stockQuantity,
    bool replace = false,
  }) async {
    try {
      emit(SellerAdPromoteLoading());
      final res = await _repository.addPromotionItem(
        promotionId: promotionId,
        itemId: itemId,
        discountType: discountType,
        discountValue: discountValue,
        stockQuantity: stockQuantity,
        replace: replace,
      );
      if (res['error'] == false) {
        emit(SellerAdPromoteActionSuccess(res['message'] ?? 'Item added to promotion!'));
      } else {
        emit(SellerAdPromoteFailure(res['message'] ?? 'Failed to join promotion'));
      }
    } catch (e) {
      emit(SellerAdPromoteFailure(e.toString()));
    }
  }
}
