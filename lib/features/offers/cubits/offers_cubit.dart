import 'package:eClassify/features/offers/models/campaign_model.dart';
import 'package:eClassify/features/offers/models/promotion_item_model.dart';
import 'package:eClassify/features/offers/repository/offers_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class OffersState {}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersSuccess extends OffersState {
  final List<CampaignModel> campaigns;
  final List<PromotionItemModel> items;
  final List<PromotionItemModel> spotlightAds;
  final String activeTab;

  OffersSuccess({
    required this.campaigns,
    required this.items,
    required this.spotlightAds,
    required this.activeTab,
  });

  OffersSuccess copyWith({
    List<CampaignModel>? campaigns,
    List<PromotionItemModel>? items,
    List<PromotionItemModel>? spotlightAds,
    String? activeTab,
  }) {
    return OffersSuccess(
      campaigns: campaigns ?? this.campaigns,
      items: items ?? this.items,
      spotlightAds: spotlightAds ?? this.spotlightAds,
      activeTab: activeTab ?? this.activeTab,
    );
  }
}

class OffersFailure extends OffersState {
  final String errorMessage;
  OffersFailure(this.errorMessage);
}

class OffersCubit extends Cubit<OffersState> {
  OffersCubit({OffersRepository? repository})
      : _repository = repository ?? OffersRepository(),
        super(OffersInitial());

  final OffersRepository _repository;

  Future<void> fetchOffers({
    String tab = 'all',
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      emit(OffersLoading());

      final results = await Future.wait([
        _repository.getCampaigns(status: 'active'),
        _repository.getSpotlightAds(
          city: city,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        ),
        _fetchItemsForTab(
          tab: tab,
          city: city,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        ),
      ]);

      final campaigns = results[0] as List<CampaignModel>;
      final spotlightAds = results[1] as List<PromotionItemModel>;
      final items = results[2] as List<PromotionItemModel>;

      emit(OffersSuccess(
        campaigns: campaigns,
        spotlightAds: spotlightAds,
        items: items,
        activeTab: tab,
      ));
    } catch (e) {
      emit(OffersFailure(e.toString()));
    }
  }

  Future<void> changeTab({
    required String tab,
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    if (state is OffersSuccess) {
      final current = state as OffersSuccess;
      try {
        emit(OffersLoading());
        final items = await _fetchItemsForTab(
          tab: tab,
          city: city,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
        emit(current.copyWith(items: items, activeTab: tab));
      } catch (e) {
        emit(OffersFailure(e.toString()));
      }
    } else {
      fetchOffers(tab: tab, city: city, latitude: latitude, longitude: longitude, radius: radius);
    }
  }

  Future<List<PromotionItemModel>> _fetchItemsForTab({
    required String tab,
    String? city,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    switch (tab) {
      case 'flash_sale':
        return await _repository.getFlashSales(
          city: city,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
      case 'deal_of_the_day':
        return await _repository.getDealsOfTheDay(
          city: city,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
      case 'clearance_sale':
        return await _repository.getClearanceSales(
          city: city,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
      default:
        return await _repository.getPromotionItems(
          city: city,
          latitude: latitude,
          longitude: longitude,
          radius: radius,
        );
    }
  }
}
