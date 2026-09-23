import 'package:eClassify/features/offers/models/seller_promotions_analytics_model.dart';
import 'package:eClassify/features/offers/repository/offers_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SellerPromotionsAnalyticsState {}

class SellerPromotionsAnalyticsInitial extends SellerPromotionsAnalyticsState {}

class SellerPromotionsAnalyticsLoading extends SellerPromotionsAnalyticsState {}

class SellerPromotionsAnalyticsSuccess extends SellerPromotionsAnalyticsState {
  final SellerPromotionsAnalyticsModel analytics;
  final List<SellerPromotionHistoryItem> history;
  final String activeFilter;
  final int currentPage;
  final int lastPage;
  final bool isLoadingHistory;

  SellerPromotionsAnalyticsSuccess({
    required this.analytics,
    required this.history,
    this.activeFilter = 'all',
    this.currentPage = 1,
    this.lastPage = 1,
    this.isLoadingHistory = false,
  });

  SellerPromotionsAnalyticsSuccess copyWith({
    SellerPromotionsAnalyticsModel? analytics,
    List<SellerPromotionHistoryItem>? history,
    String? activeFilter,
    int? currentPage,
    int? lastPage,
    bool? isLoadingHistory,
  }) {
    return SellerPromotionsAnalyticsSuccess(
      analytics: analytics ?? this.analytics,
      history: history ?? this.history,
      activeFilter: activeFilter ?? this.activeFilter,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
    );
  }
}

class SellerPromotionsAnalyticsFailure extends SellerPromotionsAnalyticsState {
  final String errorMessage;
  SellerPromotionsAnalyticsFailure(this.errorMessage);
}

class SellerPromotionsAnalyticsCubit extends Cubit<SellerPromotionsAnalyticsState> {
  SellerPromotionsAnalyticsCubit({OffersRepository? repository})
      : _repository = repository ?? OffersRepository(),
        super(SellerPromotionsAnalyticsInitial());

  final OffersRepository _repository;

  Future<void> loadDashboard({String filter = 'all'}) async {
    try {
      emit(SellerPromotionsAnalyticsLoading());
      final analyticsFuture = _repository.getPromotionsAnalytics();
      final historyFuture = _repository.getPromotionsHistory(filterType: filter, page: 1);

      final results = await Future.wait([analyticsFuture, historyFuture]);
      final analytics = results[0] as SellerPromotionsAnalyticsModel;
      final historyData = results[1] as Map<String, dynamic>;

      emit(
        SellerPromotionsAnalyticsSuccess(
          analytics: analytics,
          history: (historyData['items'] as List<SellerPromotionHistoryItem>?) ?? [],
          activeFilter: filter,
          currentPage: historyData['current_page'] as int? ?? 1,
          lastPage: historyData['last_page'] as int? ?? 1,
        ),
      );
    } catch (e) {
      emit(SellerPromotionsAnalyticsFailure(e.toString()));
    }
  }

  Future<void> changeFilter(String filter) async {
    final currentState = state;
    if (currentState is! SellerPromotionsAnalyticsSuccess) {
      await loadDashboard(filter: filter);
      return;
    }

    try {
      emit(currentState.copyWith(isLoadingHistory: true, activeFilter: filter));
      final historyData = await _repository.getPromotionsHistory(filterType: filter, page: 1);
      emit(
        currentState.copyWith(
          history: (historyData['items'] as List<SellerPromotionHistoryItem>?) ?? [],
          activeFilter: filter,
          currentPage: historyData['current_page'] as int? ?? 1,
          lastPage: historyData['last_page'] as int? ?? 1,
          isLoadingHistory: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingHistory: false));
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! SellerPromotionsAnalyticsSuccess) return;
    if (currentState.isLoadingHistory || currentState.currentPage >= currentState.lastPage) return;

    try {
      emit(currentState.copyWith(isLoadingHistory: true));
      final nextPage = currentState.currentPage + 1;
      final historyData = await _repository.getPromotionsHistory(
        filterType: currentState.activeFilter,
        page: nextPage,
      );
      final newItems = (historyData['items'] as List<SellerPromotionHistoryItem>?) ?? [];
      emit(
        currentState.copyWith(
          history: [...currentState.history, ...newItems],
          currentPage: nextPage,
          lastPage: historyData['last_page'] as int? ?? currentState.lastPage,
          isLoadingHistory: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingHistory: false));
    }
  }
}
