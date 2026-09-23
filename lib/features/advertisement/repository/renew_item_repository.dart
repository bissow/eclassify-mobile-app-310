import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';

class RenewItemRepository {
  Future<String> renewItem({
    int? itemId,
    Iterable<int>? itemIds,
    int? packageId,
  }) async {
    assert(
      (itemId != null && itemIds == null) ||
          (itemId == null && itemIds != null),
      "Either itemId or itemIds must be provided, but not both.",
    );

    final response = await Api.post(
      url: ApiEndpoints.renewItem,
      parameter: {
        ApiParams.packageId: packageId,
        ApiParams.itemId: ?itemId,
        ApiParams.itemIds: ?(itemIds.isNotNullAndNotEmpty
            ? itemIds!.join(',')
            : null),
      },
    );

    return response['message'] as String;
  }
}
