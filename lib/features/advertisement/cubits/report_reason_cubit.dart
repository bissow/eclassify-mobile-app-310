import 'package:eClassify/features/advertisement/models/report_reason.dart';
import 'package:eClassify/features/advertisement/repository/report_item_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReportReasonState {}

class ReportReasonInitial extends ReportReasonState {}

class ReportReasonLoading extends ReportReasonState {}

class ReportReasonSuccess extends ReportReasonState {
  ReportReasonSuccess({required this.reasons});
  final List<ReportReason> reasons;
}

class ReportReasonFailure extends ReportReasonState {
  ReportReasonFailure({required this.errorMessage});

  final String errorMessage;
}

class ReportReasonCubit extends Cubit<ReportReasonState> {
  ReportReasonCubit() : super(ReportReasonInitial());

  Future<void> getReasons() async {
    try {
      emit(ReportReasonLoading());

      final reasons = await ReportItemRepository().fetchReportReasons();

      emit(ReportReasonSuccess(reasons: reasons));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(ReportReasonFailure(errorMessage: e.toString()));
    }
  }

  void clear() => emit(ReportReasonInitial());
}
