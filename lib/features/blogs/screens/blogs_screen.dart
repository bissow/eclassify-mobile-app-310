import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/blogs/cubits/blog_category_cubit.dart';
import 'package:eClassify/features/blogs/cubits/blog_tag_cubit.dart';
import 'package:eClassify/features/blogs/cubits/popular_blog_list_cubit.dart';
import 'package:eClassify/features/blogs/models/blog_tag.dart';
import 'package:eClassify/features/blogs/screens/widgets/blog_category_tab_bar.dart';
import 'package:eClassify/features/blogs/screens/widgets/blog_list.dart';
import 'package:eClassify/features/blogs/screens/widgets/blog_list_shimmer.dart';
import 'package:eClassify/features/blogs/screens/widgets/blog_tag_list.dart';
import 'package:eClassify/features/blogs/screens/widgets/popular_blog_list.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({this.blogId, super.key});

  final int? blogId;

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => BlogCategoryCubit()),
          BlocProvider(create: (_) => PopularBlogListCubit()),
          BlocProvider(create: (_) => BlogTagCubit()),
        ],
        child: BlogsScreen(blogId: routeSettings.arguments as int?),
      ),
    );
  }

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen>
    with SingleTickerProviderStateMixin {
  TabController? _controller;
  final ValueNotifier<BlogTag?> _selectedTagNotifier = ValueNotifier<BlogTag?>(
    null,
  );

  @override
  void initState() {
    super.initState();
    if (widget.blogId != null) {
      Navigator.of(
        context,
      ).pushNamed(Routes.blogDetailsScreen, arguments: {'id': widget.blogId});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _selectedTagNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlogCategoryCubit, BlogCategoryState>(
      listener: (context, state) {
        if (state is BlogCategorySuccess) {
          _controller = TabController(
            length: state.categories.length,
            vsync: this,
          );
        }
      },
      child: AppScaffold(
        appBar: AppBar(
          title: Text('blogs'.translate(context)),
          bottom: BlogCategoryTabBar(controllerProvider: () => _controller),
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              context.read<BlogTagCubit>().getBlogTags();
              context.read<BlogCategoryCubit>().getBlogCategories();
              context.read<PopularBlogListCubit>().getPopularBlogs();
            },
            child: NestedScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(
                    child: BlogTagList(
                      onTagSelected: (tag) {
                        _selectedTagNotifier.value = tag;
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  SliverToBoxAdapter(child: PopularBlogList()),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  BlocBuilder<BlogCategoryCubit, BlogCategoryState>(
                    builder: (context, state) {
                      if (state is BlogCategorySuccess && _controller != null) {
                        return SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constant.horizontalPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Blogs',
                                  style: context.titleMedium,
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    },
                  ),
                ];
              },
              body: BlocBuilder<BlogCategoryCubit, BlogCategoryState>(
                builder: (context, state) {
                  if (state is BlogCategoryFailure) {
                    return QErrorWidget(
                      error: state.error,
                      onRetry: () {
                        context.read<BlogCategoryCubit>().getBlogCategories();
                      },
                    );
                  }
                  if (state is BlogCategorySuccess && _controller != null) {
                    return ListenableBuilder(
                      listenable: Listenable.merge([
                        _controller!,
                        _selectedTagNotifier,
                      ]),
                      builder: (context, _) {
                        return TabBarView(
                          controller: _controller,
                          children: [
                            ...state.categories.asMap().entries.map((entry) {
                              final index = entry.key;
                              final category = entry.value;
                              return BlogList(
                                categoryId: category.id,
                                selectedTag: _selectedTagNotifier.value,
                                isActive: _controller!.index == index,
                              );
                            }),
                          ],
                        );
                      },
                    );
                  }
                  return Padding(
                    padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
                    child: const BlogListShimmer(),
                  );
                },
              ),
            ),
          ),
      ),
    );
  }
}
