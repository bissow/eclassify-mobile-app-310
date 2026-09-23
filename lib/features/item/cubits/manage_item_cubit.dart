import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/item/models/ad_posting_data.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ManageItemState {}

class ManageItemInitial extends ManageItemState {}

class ManageItemLoading extends ManageItemState {}

class ManageItemSuccess extends ManageItemState {
  ManageItemSuccess({required this.item, required this.isUploadInProgress});

  final MyItem item;
  final bool isUploadInProgress;
}

class ManageItemFailure extends ManageItemState {
  ManageItemFailure({required this.error});

  final Exception error;
}

class ManageItemCubit extends Cubit<ManageItemState> {
  ManageItemCubit() : super(ManageItemInitial());

  Future<void> createItem({required AdPostingData data}) async {
    try {
      emit(ManageItemLoading());

      final result = await ItemRepository.instance.createAdvertisement(
        data: data,
      );

      emit(
        ManageItemSuccess(
          item: result.item,
          isUploadInProgress: result.isUploadInProgress,
        ),
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ManageItemFailure(error: e));
    }
  }
}
