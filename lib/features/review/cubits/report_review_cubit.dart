import 'package:eClassify/features/review/repository/review_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReportReviewState {}

class ReportReviewInitial extends ReportReviewState {}

class ReportReviewInProgress extends ReportReviewState {}

class ReportReviewSuccess extends ReportReviewState {
  ReportReviewSuccess({required this.reviewId, required this.reason});

  final int reviewId;
  final String reason;
}

class ReportReviewFailure extends ReportReviewState {
  ReportReviewFailure({required this.error});

  final Object? error;
}

class ReportReviewCubit extends Cubit<ReportReviewState> {
  ReportReviewCubit() : super(ReportReviewInitial());
  final _repository = ReviewRepository.instance;

  Future<void> reportReview({
    required int reviewId,
    required String reason,
  }) async {
    try {
      emit(ReportReviewInProgress());

      await _repository.reportReview(reviewId: reviewId, reason: reason);

      emit(ReportReviewSuccess(reviewId: reviewId, reason: reason));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(ReportReviewFailure(error: e));
    }
  }
}
