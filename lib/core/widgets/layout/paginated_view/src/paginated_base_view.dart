part of '../paginated_view.dart';

typedef _PaginatedViewBuilder<T> =
    Widget Function(BuildContext, List<T>, Widget?);

typedef _PaginatedViewLoadingBuilder =
    Widget Function(BuildContext, bool isForPage);

typedef _PaginatedViewErrorBuilder =
    Widget Function(
      BuildContext,
      Object error,
      Function() onRetry,
      bool isForPage,
    );

class _PaginatedBaseView<C extends PaginatedCubit<T, P>, T, P>
    extends StatefulWidget {
  _PaginatedBaseView({
    super.key,
    required this.autoFetch,
    required this.viewBuilder,
    this.loadingWidget,
    this.errorBuilder,
    this.emptyViewBuilder,
    this.parameters,
  });

  final bool autoFetch;
  final _PaginatedViewBuilder<T> viewBuilder;
  final _PaginatedViewLoadingBuilder? loadingWidget;
  final _PaginatedViewErrorBuilder? errorBuilder;
  final WidgetBuilder? emptyViewBuilder;
  final P? parameters;

  @override
  State<_PaginatedBaseView<C, T, P>> createState() =>
      _PaginatedBaseViewState<C, T, P>();
}

class _PaginatedBaseViewState<C extends PaginatedCubit<T, P>, T, P>
    extends State<_PaginatedBaseView<C, T, P>> {
  @override
  void initState() {
    super.initState();
    if (widget.autoFetch && context.read<C>().state is Initial<T>) {
      _getData();
    }
  }

  @override
  void didUpdateWidget(covariant _PaginatedBaseView<C, T, P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parameters != widget.parameters) {
      _getData(reset: true);
    }
  }

  void _getData({bool reset = false}) {
    context.read<C>().get(params: widget.parameters, reset: reset);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, PaginatedState<T>>(
      builder: (context, state) {
        return switch (state) {
          Initial() => const SizedBox.shrink(),
          Loading() => _loadingWidget(false),
          DataState<T> s => _buildDataView(s),
          Failure(:final error) => _errorWidget(error, _getData, false),
        };
      },
    );
  }

  Widget _buildDataView(DataState<T> state) {
    if (state.result.data.isEmpty) {
      return widget.emptyViewBuilder?.call(context) ??
          QErrorWidget.emptyData(onRetry: () => _getData(reset: true));
    }

    final footer = switch (state) {
      PageLoading() => _loadingWidget(true),
      PageFailure(:final error) => _errorWidget(error, _getData, true),
      _ => null,
    };

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.isNearBottom) {
          _getData();
        }
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async => _getData(reset: true),
        child: widget.viewBuilder(context, state.result.data, footer),
      ),
    );
  }

  Widget _loadingWidget(bool isPageLoading) {
    if (widget.loadingWidget != null) {
      return widget.loadingWidget!.call(context, isPageLoading);
    }
    return Center(child: LoadingIndicator());
  }

  Widget _errorWidget(Object error, Function() onRetry, bool isForPage) {
    if (widget.errorBuilder != null) {
      return widget.errorBuilder!.call(context, error, onRetry, isForPage);
    }

    if (!isForPage) {
      return QErrorWidget(error: error, onRetry: onRetry);
    }
    return Center(
      child: AppButton(
        variant: AppButtonVariant.text,
        width: AppButtonWidth.content,
        onPressed: onRetry,
        icon: Icon(AppIcons.arrowClockwise),
        title: 'retry',
      ),
    );
  }
}
