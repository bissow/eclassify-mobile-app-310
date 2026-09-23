import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/features/advertisement/repository/item_buyer_repository.dart';

class BuyerListCubit extends PaginatedCubit<UserPreview, void> {
  BuyerListCubit({required this.itemId, required this.isJobItem}) : super();
  final int itemId;
  final bool isJobItem;

  @override
  Future<PaginatedResult<UserPreview>> getPage(int page, {void params}) {
    return ItemBuyerRepository.instance.getBuyerList(
      itemId: itemId,
      isJobItem: isJobItem,
      page: page,
    );
  }
}
