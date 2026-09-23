import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/models/seo_details.dart';

final class MyItem extends Item {
  MyItem.fromJson(super.json)
    : status = ItemStatus.parse(json['status']),
      listingValue = ListingValue.parse(json),
      currency = Currency.fromJson(json['currency'] as Json),
      translations = JsonHelper.parseList(
        json['translations'] as List?,
        (json) => json,
      ),
      seoDetails = JsonHelper.parseObjectOrNull(
        json['seo_detail'] as Json?,
        SeoDetails.fromJson,
      ),
      rejectedReason = json['rejected_reason'] as String?,
      adminEditReason = json['admin_edit_reason'] as String?,
      totalLikes = json['total_likes'] as int? ?? 0,
      totalViews = json['views'] as int? ?? 0,
      super.fromJson();

  final ItemStatus status;
  final ListingValue listingValue;
  final Currency currency;
  final List<Json> translations;
  final SeoDetails? seoDetails;
  final String? rejectedReason;
  final String? adminEditReason;
  final int totalLikes;
  final int totalViews;

  bool get isRejected =>
      status == ItemStatus.softRejected ||
      status == ItemStatus.permanentRejected;
}

abstract class ListingValue {
  factory ListingValue.parse(Json json) {
    final isJobCategory = json['category']?['is_job_category'] == 1;
    if (isJobCategory) {
      return Salary.fromJson(json);
    } else {
      return Price.fromJson(json);
    }
  }

  ListingValue({required this.formattedValue});

  final String? formattedValue;
}

class Price extends ListingValue {
  Price.fromJson(Json json)
    : price = num.tryParse(json['price'].toString()),
      super(formattedValue: json['formatted_price'] as String?);
  final num? price;
}

class Salary extends ListingValue {
  Salary.fromJson(Json json)
    : minSalary = num.tryParse(json['min_salary'].toString()),
      maxSalary = num.tryParse(json['max_salary'].toString()),
      super(formattedValue: json['formatted_salary_range'] as String?);
  final num? minSalary;
  final num? maxSalary;
}
