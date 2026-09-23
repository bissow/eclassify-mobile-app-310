import 'package:eClassify/core/models/paginated_result.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

sealed class PaginatedState<T> {
  const PaginatedState();

  PaginatedState<T> toLoading() => switch (this) {
    DataState(result: final data) => PageLoading(data),
    _ => Loading(),
  };

  PaginatedState<T> toFailure(Object error) => switch (this) {
    DataState(result: final data) => PageFailure(error, data),
    _ => Failure(error),
  };

  PaginatedState<T> toSuccess(PaginatedResult<T> data, {bool reset = false}) =>
      switch (this) {
        DataState(:final result) => Success(
          PaginatedResult<T>(
            data: [if (!reset) ...result.data, ...data.data],
            total: data.total,
            metadata: data.metadata,
          ),
        ),
        _ => Success(data),
      };
}

final class Initial<T> extends PaginatedState<T> {}

final class Loading<T> extends PaginatedState<T> {}

sealed class DataState<T> extends PaginatedState<T> {
  const DataState(this.result);

  final PaginatedResult<T> result;
}

final class Success<T> extends DataState<T> {
  const Success(PaginatedResult<T> data) : super(data);
}

final class PageLoading<T> extends DataState<T> {
  const PageLoading(PaginatedResult<T> data) : super(data);
}

final class PageFailure<T> extends DataState<T> {
  const PageFailure(this.error, PaginatedResult<T> data) : super(data);
  final Object error;
}

final class Failure<T> extends PaginatedState<T> {
  const Failure(this.error);

  final Object error;
}

abstract class PaginatedCubit<T, P> extends Cubit<PaginatedState<T>> {
  PaginatedCubit() : super(Initial());

  int _page = 0;

  bool get hasMore {
    if (state case DataState s) {
      return s.result.data.length < s.result.total;
    }
    return false;
  }

  @protected
  Future<PaginatedResult<T>> getPage(int page, {P? params});

  bool _isFetching = false;

  Future<void> get({bool reset = false, P? params}) async {
    // Allow reset to bypass the debounce lock
    if (_isFetching && !reset) return;

    if (!reset) {
      // 1. Prevent duplicate fetches while already loading
      if (state is Loading<T> || state is PageLoading<T>) return;
      // 2. Prevent fetching past the total count only when in a DataState
      if (state is DataState<T> && !hasMore) return;
    }

    try {
      _isFetching = true;
      if (reset) {
        _page = 0;
      }
      emit(reset ? Loading() : state.toLoading());
      final result = await getPage(_page + 1, params: params);
      emit(state.toSuccess(result, reset: reset));
      _page++;
    } catch (e, st) {
      Log.error(e.toString(), e, st);
      emit(state.toFailure(e));
    } finally {
      // Add a small delay before allowing the next fetch.
      // This prevents rapid-fire triggers from ScrollNotifications 
      // before the UI has had a chance to render the new items and update scroll metrics.
      Future.delayed(const Duration(milliseconds: 300), () {
        _isFetching = false;
      });
    }
  }

  void clearState() {
    _page = 0;
    emit(Initial());
  }
}
