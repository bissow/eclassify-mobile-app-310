import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ItemStatusState {}

class ItemStatusInitial extends ItemStatusState {}

class ItemStatusLoading extends ItemStatusState {}

class ItemStatusSuccess extends ItemStatusState {
  ItemStatusSuccess({required this.status, this.message});

  final ItemStatus status;
  final String? message;
}

class ItemStatusFailure extends ItemStatusState {
  ItemStatusFailure({required this.message});

  final String message;
}

class ItemStatusCubit extends Cubit<ItemStatusState> {
  ItemStatusCubit() : super(ItemStatusInitial());

  Future<void> getItemStatus({required int itemId}) async {
    try {
      emit(ItemStatusLoading());

      final status = await ItemRepository.instance.getItemStatus(
        itemId: itemId,
      );

      emit(ItemStatusSuccess(status: status));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(ItemStatusFailure(message: e.toString()));
    }
  }

  Future<void> changeItemStatus({
    required int itemId,
    required ItemStatus status,
    int? userId,
  }) async {
    try {
      emit(ItemStatusLoading());
      final response = await ItemRepository.instance.changeItemStatus(
        itemId: itemId,
        status: status,
        soldTo: userId,
      );
      emit(ItemStatusSuccess(status: status, message: response));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(ItemStatusFailure(message: e.toString()));
    }
  }
}
