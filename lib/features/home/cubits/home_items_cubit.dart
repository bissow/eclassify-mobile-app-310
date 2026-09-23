import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/home/repository/home_repository.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';

class HomeItemsCubit extends PaginatedCubit<ItemPreview, LeafLocation> {
  HomeItemsCubit() : super();

  @override
  Future<PaginatedResult<ItemPreview>> getPage(
    int page, {
    LeafLocation? params,
  }) async {
    return HomeRepository.instance.fetchHomeAllItems(
      location: params,
      page: page,
    );
  }
}
