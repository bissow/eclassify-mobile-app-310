part of 'paginated_view.dart';

class PaginatedListView<C extends PaginatedCubit<T, P>, T, P>
    extends StatelessWidget {
  const PaginatedListView({
    required this.itemBuilder,
    this.autoFetch = true,
    this.separatorBuilder,
    this.parameters,
    this.padding,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyViewBuilder,
    super.key,
  });

  final bool autoFetch;
  final PaginatedItemBuilder<T> itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final P? parameters;
  final EdgeInsetsGeometry? padding;
  final _PaginatedViewLoadingBuilder? loadingBuilder;
  final _PaginatedViewErrorBuilder? errorBuilder;
  final WidgetBuilder? emptyViewBuilder;

  @override
  Widget build(BuildContext context) {
    return _PaginatedBaseView<C, T, P>(
      autoFetch: autoFetch,
      parameters: parameters,
      loadingWidget: loadingBuilder,
      errorBuilder: errorBuilder,
      emptyViewBuilder: emptyViewBuilder,
      viewBuilder: (context, items, footer) {
        final total = items.length + (footer != null ? 1 : 0);
        if (separatorBuilder == null) {
          return ListView.builder(
            itemCount: total,
            padding: padding,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return footer!;
              }
              return itemBuilder(context, items[index]);
            },
          );
        } else {
          return ListView.separated(
            itemCount: total,
            padding: padding,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return footer!;
              }
              return itemBuilder(context, items[index]);
            },
            separatorBuilder: separatorBuilder!,
          );
        }
      },
    );
  }
}
