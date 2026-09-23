import 'package:eClassify/features/banner/models/banner_ad.dart';
import 'package:eClassify/features/banner/models/banner_ad_factory.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/log.dart';

class BannerRepository {
  BannerRepository._();

  static final _instance = BannerRepository._();

  static BannerRepository get instance => _instance;

  Future<List<BannerAd>> fetchBannerAds({required String page}) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getBannerAds,
        queryParameters: {'page': page, 'platform': 'app'},
      );

      final data = response['data'] as List;

      return data.map((item) => BannerAdFactory.createBannerAd(item)).toList();
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }
}
