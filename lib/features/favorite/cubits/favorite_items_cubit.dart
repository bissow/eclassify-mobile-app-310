import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/favorite/repository/favourites_repository.dart';

class FavoriteItemsCubit extends PaginatedCubit<ItemPreview, void> {
  @override
  Future<PaginatedResult<ItemPreview>> getPage(int page, {void params}) {
    return FavoriteRepository.instance.getFavoriteItems(page: page);
  }
}
