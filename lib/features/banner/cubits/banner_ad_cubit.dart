import 'package:eClassify/features/banner/repository/banner_repository.dart';
import 'package:eClassify/features/banner/models/banner_ad.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef HomeSectionBannerKey = (int sectionId, BannerPlacement placement);
typedef HomeSectionBannerMap = Map<HomeSectionBannerKey, HomeBannerAd>;

typedef DetailBannerKey = (DetailSection section, BannerPlacement placement);
typedef DetailBannerMap = Map<DetailBannerKey, DetailBannerAd>;

abstract class BannerAdState {}

class BannerAdInitial extends BannerAdState {}

class BannerAdLoading extends BannerAdState {}

class BannerAdSuccess<T extends BannerAd> extends BannerAdState {
  BannerAdSuccess({required this.bannerAds});

  final List<T> bannerAds;
}

class BannerAdFailure extends BannerAdState {
  BannerAdFailure(this.error);

  final Object error;
}

abstract class BannerAdCubit extends Cubit<BannerAdState> {
  BannerAdCubit() : super(BannerAdInitial());

  final BannerRepository _repository = BannerRepository.instance;

  String get page;

  Future<void> fetchBanners() async {
    try {
      emit(BannerAdLoading());

      final ads = await _repository.fetchBannerAds(page: page);

      emit(BannerAdSuccess(bannerAds: ads));
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(BannerAdFailure(e));
    }
  }
}

final class HomeBannerAdCubit extends BannerAdCubit {
  List<HomeBannerAd> homeBanners = List.empty(growable: true);
  List<HomeBannerAd> featuredBanners = List.empty(growable: true);

  HomeSectionBannerMap homeBannersByKey = {};
  HomeSectionBannerMap featuredBannersByKey = {};

  @override
  String get page => 'home';

  @override
  Future<void> fetchBanners() async {
    homeBanners.clear();
    featuredBanners.clear();
    homeBannersByKey.clear();
    featuredBannersByKey.clear();
    await super.fetchBanners();
    if (state is! BannerAdSuccess) return;
    final banners = ((state as BannerAdSuccess).bannerAds as List)
        .cast<HomeBannerAd>();

    for (final HomeBannerAd banner in banners) {
      if (banner.featuredSectionId != null) {
        featuredBanners.add(banner);
        featuredBannersByKey[(banner.featuredSectionId!, banner.placement)] =
            banner;
      } else {
        homeBanners.add(banner);
        homeBannersByKey[(banner.homeSectionId, banner.placement)] = banner;
      }
    }
  }
}

class DetailBannerAdCubit extends BannerAdCubit {
  DetailBannerMap bannersByKey = {};

  @override
  String get page => 'detail';

  @override
  Future<void> fetchBanners() async {
    bannersByKey.clear();
    await super.fetchBanners();
    if (state is! BannerAdSuccess) return;
    final banners = ((state as BannerAdSuccess).bannerAds as List)
        .cast<DetailBannerAd>();

    for (final DetailBannerAd banner in banners) {
      bannersByKey[(banner.section, banner.placement)] = banner;
    }
  }
}
