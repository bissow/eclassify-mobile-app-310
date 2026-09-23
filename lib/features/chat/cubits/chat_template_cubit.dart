import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/chat/repository/chat_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatTemplateCubit extends Cubit<List<String>> {
  ChatTemplateCubit() : super(List<String>.empty());

  Future<void> getChatTemplates({required int itemId}) async {
    try {
      final templates = await ChatRepository.instance.getChatTemplates(
        itemId: itemId,
      );

      emit(List.from(templates));
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
    }
  }
}
