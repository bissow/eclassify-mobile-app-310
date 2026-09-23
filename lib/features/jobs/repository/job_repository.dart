import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eClassify/core/models/data_output.dart';
import 'package:eClassify/features/jobs/models/job_application.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:path/path.dart' as path;

class JobRepository {
  Future<dynamic> applyJobApplication(
    Map<String, dynamic> data,
    File? attachment,
  ) async {
    Map<String, dynamic> parameters = {};
    parameters.addAll(data);

    if (attachment != null) {
      MultipartFile image = await MultipartFile.fromFile(
        attachment.path,
        filename: path.basename(attachment.path),
      );
      parameters[ApiParams.resume] = image;
    }

    Map<String, dynamic> response = await Api.post(
      url: ApiEndpoints.applyForJob,
      parameter: parameters,
    );

    return response;
  }

  Future<DataOutput<JobApplication>> fetchApplications({
    int? page,
    int? itemId,
    required bool isMyJobApplications,
  }) async {
    try {
      Map<String, dynamic> parameters = {ApiParams.page: ?page, ApiParams.itemId: ?itemId};

      Map<String, dynamic> response = await Api.get(
        url: isMyJobApplications
            ? ApiEndpoints.myJobApplications
            : ApiEndpoints.getJobApplications,
        queryParameters: parameters,
      );
      if ((response['data']['data'] as List).isNotEmpty) {
        List<JobApplication> itemList = (response['data']['data'] as List)
            .map((element) => JobApplication.fromJson(element))
            .toList();

        return DataOutput(total: itemList.length, modelList: itemList);
      } else {
        return DataOutput(total: response['data']['total'] ?? 0, modelList: []);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map> changeJobApplicationStatus({
    required int jobId,
    required String status,
  }) async {
    Map response = await Api.post(
      url: ApiEndpoints.updateJobApplicationsStatus,
      parameter: {ApiParams.status: status, ApiParams.jobId: jobId},
    );
    return response;
  }
}
