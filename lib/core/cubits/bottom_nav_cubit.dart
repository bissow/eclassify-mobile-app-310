import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

enum BottomTab { home, chat, videoAds, profile }

class BottomNavState {
  BottomNavState({required this.activeTab, required this.isVisible});

  factory BottomNavState.initial() =>
      BottomNavState(activeTab: BottomTab.home, isVisible: true);

  final BottomTab activeTab;
  final bool isVisible;

  BottomNavState copyWith({BottomTab? activeTab, bool? isVisible}) =>
      BottomNavState(
        activeTab: activeTab ?? this.activeTab,
        isVisible: isVisible ?? this.isVisible,
      );
}

class BottomNavCubit extends Cubit<BottomNavState> {
  BottomNavCubit() : super(BottomNavState.initial());

  final StreamController<BottomTab> _streamController =
      StreamController<BottomTab>.broadcast();

  Stream<BottomTab> get taps => _streamController.stream;

  void changeTab(BottomTab tab) {
    if (state.activeTab == tab) {
      _streamController.add(tab);
    }
    emit(state.copyWith(activeTab: tab));
  }

  void show() {
    if (state.isVisible) return;
    emit(state.copyWith(isVisible: true));
  }

  void hide() {
    if (!state.isVisible) return;
    emit(state.copyWith(isVisible: false));
  }

  @override
  Future<void> close() {
    _streamController.close();
    return super.close();
  }
}
