import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/features/subscription/models/subscription_package.dart';
import 'package:eClassify/features/subscription/models/transaction.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:path/path.dart' as path;

class SubscriptionRepository {
  SubscriptionRepository._internal();

  static final _instance = SubscriptionRepository._internal();

  static SubscriptionRepository get instance => _instance;

  Future<List<SubscriptionPackage>> getPackages({
    required SubscriptionPackageType type,
    int? categoryId,
    AdItemType? adItemType,
    bool isRenew = false,
  }) async {
    try {
      final effectiveId = categoryId == null || categoryId <= 0
          ? null
          : categoryId;

      final response = await Api.get(
        url: ApiEndpoints.getPackage,
        queryParameters: {
          ApiParams.type: type.label,
          ApiParams.categoryId: ?effectiveId,
          // `get-package` filters by listing type; `get-active-packages`
          // below takes the same value as `item_type`.
          'listing_type': ?adItemType?.value,
          if (isRenew) 'is_renew': 1,
        },
      );

      return JsonHelper.parseList(
        response['data'] as List?,
        SubscriptionPackage.fromJson,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<List<SubscriptionPackage>> getActivePackages({
    SubscriptionPackageType? type,
    int? categoryId,
    AdItemType? adItemType,
  }) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getActivePackages,
        queryParameters: {
          'category_id': ?categoryId,
          'type': ?type?.label,
          if (adItemType != null)
            'item_type': adItemType == AdItemType.regularAd ? 'normal' : 'reel',
        },
      );

      return JsonHelper.parseList(
        response['data'] as List?,
        SubscriptionPackage.fromJson,
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<String> assignFreePackage({required int packageId}) async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.assignFreePackage,
        parameter: {ApiParams.packageId: packageId},
      );

      return response['message'] as String;
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<void> fetchUserPackageLimit({
    required SubscriptionPackageType packageType,
  }) async {
    try {
      await Api.get(
        url: ApiEndpoints.getLimitsOfPackage,
        queryParameters: {ApiParams.packageType: packageType.label},
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<String> uploadBankTransferReceipt({
    required int transactionId,
    required File receipt,
  }) async {
    try {
      final image = await MultipartFile.fromFile(
        receipt.path,
        filename: path.basename(receipt.path),
      );

      final response = await Api.post(
        url: ApiEndpoints.bankTransferUpdate,
        parameter: {
          ApiParams.paymentTransactionId: transactionId,
          ApiParams.paymentReceipt: image,
        },
      );

      return response['message'] as String;
    } on ApiException catch (e, st) {
      Log.error(e.toString(), e, st);
      rethrow;
    }
  }

  Future<PaginatedResult<Transaction>> getTransactions(int page) async {
    try {
      final response = await Api.get(
        url: ApiEndpoints.getPaymentDetails,
        queryParameters: {ApiParams.page: page},
      );

      final transactions = JsonHelper.parseList(
        response['data']['data'] as List?,
        Transaction.fromJson,
      );
      final total = response['data']['total'] as int;

      return PaginatedResult(data: transactions, total: total);
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      rethrow;
    }
  }

  Future<String> getPaymentReceipt({required int transactionId}) async {
    final response = await Api.getRaw(
      url: ApiEndpoints.paymentReceipt,
      queryParameters: {'payment_transaction_id': transactionId},
    );

    return response;
  }
}
