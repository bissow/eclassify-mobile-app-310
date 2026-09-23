import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';

class MyItemsCubit extends PaginatedCubit<MyItemPreview, void> {
  MyItemsCubit(this.status) : super();
  final String? status;

  @override
  Future<PaginatedResult<MyItemPreview>> getPage(int page, {void params}) {
    return ItemRepository.instance.getMyItems(page: page, status: status);
  }

  void deleteItemsLocally(Set<int> ids) {
    if (state is! DataState) return;
    final result = (state as DataState<MyItemPreview>).result;
    final data = result.data;
    int totalDeleted = 0;
    data.removeWhere((item) {
      final shouldRemove = ids.contains(item.id);
      if (shouldRemove) totalDeleted++;
      return shouldRemove;
    });
    final updatedResult = result.copyWithData(
      data,
      result.total - totalDeleted,
    );
    emit(state.toSuccess(updatedResult, reset: true));
  }
}
