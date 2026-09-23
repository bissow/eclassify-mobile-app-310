import 'package:eClassify/features/advertisement/repository/report_item_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ItemReportState {}

class ItemReportInitial extends ItemReportState {}

class ItemReportLoading extends ItemReportState {}

class ItemReportSuccess extends ItemReportState {
  ItemReportSuccess({required this.message});

  final String message;
}

class ItemReportFailure extends ItemReportState {
  ItemReportFailure({required this.message});

  final String message;
}

class ItemReportCubit extends Cubit<ItemReportState> {
  ItemReportCubit() : super(ItemReportInitial());

  Future<void> report({
    required int itemId,
    int? reasonId,
    String? message,
  }) async {
    try {
      emit(ItemReportLoading());

      final response = await ReportItemRepository().reportItem(
        itemId: itemId,
        reasonId: reasonId,
        message: message,
      );

      emit(ItemReportSuccess(message: response));
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(ItemReportFailure(message: e.toString()));
    }
  }
}
