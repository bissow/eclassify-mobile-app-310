import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateFeaturedAdState {}

class CreateFeaturedAdInitial extends CreateFeaturedAdState {}

class CreateFeaturedAdLoading extends CreateFeaturedAdState {}

class CreateFeaturedAdSuccess extends CreateFeaturedAdState {
  CreateFeaturedAdSuccess({required this.responseMessage});

  final String responseMessage;
}

class CreateFeaturedAdFailure extends CreateFeaturedAdState {
  CreateFeaturedAdFailure({required this.error});

  final String error;
}

class CreateFeaturedAdCubit extends Cubit<CreateFeaturedAdState> {
  CreateFeaturedAdCubit() : super(CreateFeaturedAdInitial());

  void createFeaturedAds({required int itemId}) async {
    try {
      emit(CreateFeaturedAdLoading());

      final response = await ItemRepository.instance.createFeaturedAds(
        itemId: itemId,
      );

      emit(CreateFeaturedAdSuccess(responseMessage: response));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(CreateFeaturedAdFailure(error: e.toString()));
    }
  }
}
