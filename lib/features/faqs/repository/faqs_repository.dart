import 'package:eClassify/core/models/data_output.dart';
import 'package:eClassify/features/faqs/models/faqs_model.dart';
import 'package:eClassify/core/network/api.dart';

class FaqsRepository {
  Future<DataOutput<FaqsModel>> fetchFaqs({required int page}) async {
    Map<String, dynamic> parameters = {
      ApiParams.page: page,
    };

    Map<String, dynamic> result =
        await Api.get(url: ApiEndpoints.getFaq, queryParameters: parameters);

    List<FaqsModel> modelList = (result['data'] as List)
        .map((element) => FaqsModel.fromJson(element))
        .toList();

    return DataOutput<FaqsModel>(total: modelList.length, modelList: modelList);
  }
}
