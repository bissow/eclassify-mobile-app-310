import 'package:eClassify/core/storage/theme_storage.dart';
// ignore_for_file: depend_on_referenced_packages

import 'package:eClassify/app/session/app_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppThemeCubit extends Cubit<ThemeMode> {
  AppThemeCubit() : super(ThemeMode.light) {
    final currentTheme = ThemeStorage.getCurrentTheme();
    if (state != currentTheme) {
      emit(currentTheme);
    }
  }

  void toggleTheme() {
    final toggledTheme = state == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    ThemeStorage.setCurrentTheme(toggledTheme);
    AppSession.setCurrentTheme(toggledTheme);
    emit(toggledTheme);
  }

  bool isDarkMode() {
    return state == ThemeMode.dark;
  }
}
