import 'package:eClassify/core/cubits/language_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

extension Translate on String {
  String translate(
    BuildContext context, [
    Map<String, String> parameters = const {},
  ]) {
    var translatedText = context.read<LanguageCubit>().translate(this);
    for (final entry in parameters.entries) {
      final key = entry.key;
      final value = entry.value;
      translatedText = translatedText.replaceAll('{$key}', value);
    }
    return translatedText;
  }
}

extension CaseExtensions on String {
  String get capitalize => '${this[0].toUpperCase()}${substring(1)}';
}
