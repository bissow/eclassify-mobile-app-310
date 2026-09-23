import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';

class ItemListCubit extends PaginatedCubit<ItemPreview, ItemMetaData> {
  @override
  Future<PaginatedResult<ItemPreview>> getPage(
    int page, {
    ItemMetaData? params,
  }) {
    return ItemRepository.instance.getItem(metadata: params!, page: page);
  }
}
