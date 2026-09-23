part of 'paginated_view.dart';

class PaginatedGridView<C extends PaginatedCubit<T, P>, T, P>
    extends StatelessWidget {
  const PaginatedGridView({
    required this.itemBuilder,
    required this.gridDelegate,
    this.autoFetch = true,
    this.parameters,
    this.padding,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyViewBuilder,
    super.key,
  });

  final bool autoFetch;
  final PaginatedItemBuilder<T> itemBuilder;
  final SliverGridDelegate gridDelegate;
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
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: padding ?? EdgeInsets.zero,
              sliver: SliverGrid.builder(
                gridDelegate: gridDelegate,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return itemBuilder(context, items[index]);
                },
              ),
            ),
            if (footer != null) SliverToBoxAdapter(child: footer),
          ],
        );
      },
    );
  }
}
