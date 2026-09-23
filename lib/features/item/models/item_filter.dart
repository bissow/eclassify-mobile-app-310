import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/core/utils/json_helper.dart';

enum PostedSince {
  allTime('all_time', 'all-time'),
  today('today', 'today'),
  within1Week('within_1_week', 'within-1-week'),
  within2Week('within_2_week', 'within-2-week'),
  within1Month('within_1_month', 'within-1-month'),
  within3Month('within_3_month', 'within-3-month');

  const PostedSince(this.label, this.value);

  final String label;
  final String value;
}

class ItemFilter {
  final int? maxPrice;
  final int? minPrice;
  final Category? category;
  final PostedSince? postedSince;
  final LeafLocation? location;
  final Map<String, dynamic>? customFields;

  ItemFilter({
    this.maxPrice,
    this.minPrice,
    this.category,
    this.postedSince,
    this.location,
    this.customFields = const {},
  });

  ItemFilter copyWith({
    int? maxPrice,
    int? minPrice,
    Category? category,
    PostedSince? postedSince,
    LeafLocation? location,
    Map<String, dynamic>? customFields,
  }) {
    return ItemFilter(
      maxPrice: maxPrice ?? this.maxPrice,
      minPrice: minPrice ?? this.minPrice,
      category: category ?? this.category,
      postedSince: postedSince ?? this.postedSince,
      location: location ?? this.location,
      customFields: customFields ?? this.customFields,
    );
  }

  Json get toJson => <String, dynamic>{
    'max_price': ?maxPrice,
    'min_price': ?minPrice,
    'category_id': ?category?.id,
    'posted_since': ?postedSince?.value,
    ...?customFields,
    ...?location?.toApiJson,
  };
}
