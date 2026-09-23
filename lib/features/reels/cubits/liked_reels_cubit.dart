import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/reels/models/video_ad.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/reels/repository/video_ad_repository.dart';

class LikedReelsCubit extends PaginatedCubit<VideoAd, void> with SessionScoped {
  @override
  Future<PaginatedResult<VideoAd>> getPage(int page, {void params}) {
    return VideoAdRepository.instance.getLikedReels(page: page);
  }

  @override
  void clearSessionState() => emit(Initial());

  void removeLikedReel(int reelId) {
    if (state is! DataState) return;
    final dataState = state as DataState<VideoAd>;
    final newData = dataState.result.copyWithData(
      dataState.result.data.where((ad) => ad.id != reelId).toList(),
      dataState.result.total - 1,
    );
    emit(dataState.toSuccess(newData, reset: true));
  }
}
