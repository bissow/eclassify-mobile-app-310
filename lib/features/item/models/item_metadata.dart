import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/item/models/item_filter.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/network/api_params.dart';
import 'package:eClassify/core/utils/json_helper.dart';

enum Sort {
  popular('popular', 'popular_items'),
  newToOld('newToOld', 'new-to-old'),
  oldToNew('oldToNew', 'old-to-new'),
  priceHighToLow('priceHighToLow', 'price-high-to-low'),
  priceLowToHigh('priceLowToHigh', 'price-low-to-high');

  const Sort(this.label, this.value);

  final String label;
  final String value;
}

@immutable
sealed class ItemMetaData {
  ItemMetaData({
    required this.title,
    this.search,
    this.sortBy,
    ItemFilter? filter,
  }) : filter = filter ?? ItemFilter();

  final String title;
  final String? search;
  final Sort? sortBy;
  final ItemFilter filter;

  Json get toJson => {
    if (search.isNotNullAndNotEmpty) ApiParams.search: search,
    ApiParams.sortBy: ?sortBy?.value,
    ...filter.toJson,
  };

  ItemMetaData copyWith({
    String? search,
    Sort? sortBy,
    ItemFilter? filter,
    bool clearSearch = false,
    bool clearSortBy = false,
  });
}

class SectionMetaData extends ItemMetaData {
  SectionMetaData({
    required this.sectionId,
    required super.title,
    super.search,
    super.sortBy,
    super.filter,
  });

  final int sectionId;

  @override
  Json get toJson => {ApiParams.featuredSectionId: sectionId, ...super.toJson};

  @override
  SectionMetaData copyWith({
    String? search,
    Sort? sortBy,
    ItemFilter? filter,
    bool clearSearch = false,
    bool clearSortBy = false,
  }) {
    return SectionMetaData(
      sectionId: sectionId,
      title: title,
      search: clearSearch ? null : (search ?? this.search),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      filter: filter ?? this.filter,
    );
  }
}

class CategoryMetaData extends ItemMetaData {
  CategoryMetaData({
    required this.category,
    super.search,
    super.sortBy,
    ItemFilter? filter,
  }) : super(
         filter: filter ?? ItemFilter(category: category),
         title: category.name.localized,
       );

  final Category category;

  @override
  CategoryMetaData copyWith({
    String? search,
    Sort? sortBy,
    ItemFilter? filter,
    bool clearSearch = false,
    bool clearSortBy = false,
  }) {
    return CategoryMetaData(
      category: category,
      search: clearSearch ? null : (search ?? this.search),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      filter: filter ?? this.filter,
    );
  }
}

class SearchMetaData extends ItemMetaData {
  SearchMetaData({
    required super.title,
    super.search,
    super.sortBy,
    super.filter,
  });

  @override
  SearchMetaData copyWith({
    String? search,
    Sort? sortBy,
    ItemFilter? filter,
    bool clearSearch = false,
    bool clearSortBy = false,
  }) {
    return SearchMetaData(
      title: title,
      search: clearSearch ? null : (search ?? this.search),
      sortBy: clearSortBy ? null : (sortBy ?? this.sortBy),
      filter: filter ?? this.filter,
    );
  }
}
