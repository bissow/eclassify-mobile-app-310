import 'dart:convert';

import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/repository/system_repository.dart';
import 'package:eClassify/core/storage/language_storage.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/core/utils/timeago_messages.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoading extends LanguageState {}

class LanguageSuccess extends LanguageState {}

class LanguageFetchSuccess extends LanguageSuccess {
  LanguageFetchSuccess({required this.language});

  final Language language;
}

class LanguageFallbackSuccess extends LanguageSuccess {}

class LanguageFailure extends LanguageState {
  LanguageFailure({required this.error});

  final Object error;
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  Map<String, String> _translations = <String, String>{};

  Future<void> loadLanguage(Language language) async {
    try {
      emit(LanguageLoading());

      if (language.languageCode == 'en' && kDebugMode) {
        await _loadFromAsset();
      } else {
        final languageData = await SystemRepository.instance.getLanguage(
          languageCode: language.languageCode,
        );

        // This param is json data which contains all the translations.
        _translations = _castTranslations(languageData['file_name']);
      }

      final bool shouldStore = AppSession.currentLanguage?.id != language.id;
      if (shouldStore) {
        await LanguageStorage.storeLanguage(language);
      }

      AppSession.setCurrentLanguage(language);
      TimeagoMessages.applyLocale();

      emit(LanguageFetchSuccess(language: language));
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      _loadFallback();
    }
  }

  void reload() {
    _loadFromAsset();
  }

  Future<void> _loadFromAsset() async {
    final jsonString = await rootBundle.loadString(
      'assets/languages/language.json',
    );
    _translations = _castTranslations(json.decode(jsonString));
  }

  Future<void> _loadFallback() async {
    try {
      await _loadFromAsset();

      AppSession.setCurrentLanguage(null);
      TimeagoMessages.applyLocale();
      LanguageStorage.clearLanguage();

      emit(LanguageFallbackSuccess());
    } on Exception catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(LanguageFailure(error: e));
    }
  }

  Map<String, String> _castTranslations(dynamic raw) =>
      (raw as Map?)?.cast<String, String>() ?? {};

  String translate(String key) => _translations[key] ?? key;
}
