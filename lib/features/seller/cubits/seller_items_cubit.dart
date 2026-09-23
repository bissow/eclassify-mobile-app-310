import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';

class SellerItemsCubit extends PaginatedCubit<ItemPreview, int> {
  @override
  Future<PaginatedResult<ItemPreview>> getPage(int page, {int? params}) {
    return ItemRepository.instance.getSellerItems(
      page: page,
      sellerId: params!,
    );
  }
}
