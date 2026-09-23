import 'package:eClassify/features/advertisement/models/report_reason.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/core/utils/log.dart';

class ReportItemRepository {
  factory ReportItemRepository() => _instance;

  ReportItemRepository._internal();

  static final ReportItemRepository _instance =
      ReportItemRepository._internal();

  Future<List<ReportReason>> fetchReportReasons() async {
    try {
      final response = await Api.get(url: ApiEndpoints.getReportReasons);

      final reasons = JsonHelper.parseList(
        response['data']['data'] as List?,
        ReportReason.fromJson,
      );

      return reasons;
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      throw ApiException(e.toString());
    }
  }

  Future<String> reportItem({
    required int itemId,
    int? reasonId,
    String? message,
  }) async {
    try {
      final response = await Api.post(
        url: ApiEndpoints.addReports,
        parameter: {
          ApiParams.itemId: itemId,
          ApiParams.reportReasonId: ?reasonId,
          ApiParams.otherMessage: ?message,
        },
      );

      return response['message'] as String;
    } catch (e) {
      rethrow;
    }
  }
}
