import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/repository/review_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AddItemReviewState {}

class AddItemReviewInitial extends AddItemReviewState {}

class AddItemReviewInProgress extends AddItemReviewState {}

class AddItemReviewSuccess extends AddItemReviewState {
  AddItemReviewSuccess({required this.review});

  final Review review;
}

class AddItemReviewFailure extends AddItemReviewState {
  AddItemReviewFailure({required this.error});

  final Object? error;
}

class AddItemReviewCubit extends Cubit<AddItemReviewState> {
  AddItemReviewCubit() : super(AddItemReviewInitial());
  final _repository = ReviewRepository.instance;

  Future<void> addItemReview({
    required int itemId,
    required int rating,
    required String comment,
  }) async {
    try {
      emit(AddItemReviewInProgress());

      final review = await _repository.reviewItem(
        itemId: itemId,
        rating: rating,
        review: comment,
      );

      emit(AddItemReviewSuccess(review: review));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(AddItemReviewFailure(error: e));
    }
  }
}
