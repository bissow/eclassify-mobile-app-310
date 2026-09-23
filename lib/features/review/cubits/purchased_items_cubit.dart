import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/review/models/purchased_item.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';

class PurchasedItemsCubit extends PaginatedCubit<PurchasedItem, void> {
  @override
  Future<PaginatedResult<PurchasedItem>> getPage(int page, {void params}) {
    return ItemRepository.instance.getMyPurchasedItem(page: page);
  }

  void addReview({required int itemId, required Review review}) {
    if (state is! DataState) return;
    final result = (state as DataState<PurchasedItem>).result;
    final data = result.data;
    final index = data.indexWhere((element) => element.item.id == itemId);
    data[index] = data[index].copyWith(review: review);
    emit(state.toSuccess(result.copyWithData(data, result.total), reset: true));
  }
}
