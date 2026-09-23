import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/item/repository/item_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum OfferTrigger { offer, chat }

abstract class ItemOfferState {}

class ItemOfferInitial extends ItemOfferState {}

class ItemOfferLoading extends ItemOfferState {
  ItemOfferLoading(this.trigger);

  final OfferTrigger trigger;
}

class ItemOfferSuccess extends ItemOfferState {
  ItemOfferSuccess({required this.chat});

  final Chat chat;
}

class ItemOfferFailure extends ItemOfferState {
  ItemOfferFailure({required this.errorMessage});

  final String errorMessage;
}

class ItemOfferCubit extends Cubit<ItemOfferState> {
  ItemOfferCubit() : super(ItemOfferInitial());

  Future<void> createOffer({required int id, double? amount}) async {
    try {
      emit(
        ItemOfferLoading(
          amount != null ? OfferTrigger.offer : OfferTrigger.chat,
        ),
      );

      final chat = await ItemRepository.instance.createOffer(id, amount);

      emit(ItemOfferSuccess(chat: chat));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(ItemOfferFailure(errorMessage: e.toString()));
    }
  }
}
