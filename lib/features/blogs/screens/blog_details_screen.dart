import 'package:eClassify/features/blogs/cubits/blog_details_cubit.dart';
import 'package:eClassify/features/blogs/cubits/blog_feedback_cubit.dart';
import 'package:eClassify/features/blogs/models/blog.dart';
import 'package:eClassify/features/blogs/screens/widgets/blog_category_badge.dart';
import 'package:eClassify/features/blogs/screens/widgets/blog_feedback_widget.dart';
import 'package:eClassify/features/blogs/screens/widgets/blog_item.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/deep_link/deep_link_aware_mixin.dart';
import 'package:eClassify/core/deep_link/deep_link_handler.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/utils/share_utility.dart';
import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/tap_guard.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class BlogDetailsScreen extends StatefulWidget {
  BlogDetailsScreen({this.id, this.slug, super.key})
    : assert(id != null || slug != null, 'Either id or slug must be provided');
  final int? id;
  final String? slug;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => BlogDetailsCubit()),
          BlocProvider(create: (_) => BlogFeedbackCubit()),
        ],
        child: BlogDetailsScreen(
          id: args?['id'] as int?,
          slug: args?['slug'] as String?,
        ),
      ),
    );
  }

  @override
  State<BlogDetailsScreen> createState() => _BlogDetailsScreenState();
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen>
    with DeepLinkAware<BlogDetailsScreen, BlogDeepLink> {
  final TapGuard _guard = TapGuard();

  late int? blogId = widget.id;
  late String? blogSlug = widget.slug;

  @override
  DeepLinkHandler<BlogDeepLink> createHandler() {
    return BlogLinkHandler(
      onSlug: (slug) {
        if (blogSlug != slug) {
          context.read<BlogDetailsCubit>().getBlogDetails(slug: slug);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('blogs'.translate(context)),
        actions: [
          IconButton(
            onPressed: () {
              final state = context.read<BlogDetailsCubit>().state;
              final blogSlug = switch (state) {
                BlogDetailsSuccess(blog: final blog) => blog.slug,
                _ => null,
              };

              if (blogSlug == null) return;

              _guard.run(() async {
                ShareUtility.share(context, BlogDeepLink(blogSlug));
              });
            },
            icon: Icon(AppIcons.shareNetwork),
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.only(top: 20),
          child: BlocConsumer<BlogDetailsCubit, BlogDetailsState>(
            listener: (context, state) {
              if (state is BlogDetailsSuccess) {
                blogId = state.blog.id;
                blogSlug = state.blog.slug;
              }
            },
            builder: (context, state) {
              if (state is BlogDetailsInitial) {
                context.read<BlogDetailsCubit>().getBlogDetails(
                  id: blogId,
                  slug: blogSlug,
                );
              }
              if (state is BlogDetailsFailure) {
                return QErrorWidget(
                  error: state.error,
                  onRetry: () {
                    context.read<BlogDetailsCubit>().getBlogDetails(
                      id: blogId,
                      slug: blogSlug,
                    );
                  },
                );
              }
              if (state is BlogDetailsSuccess) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 20,
                    children: [
                      _BlogDetails(blog: state.blog),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: Constant.horizontalPadding,
                        ),
                        child: BlogFeedbackWidget(
                          key: ValueKey(state.blog.id),
                          blog: state.blog,
                        ),
                      ),
                      if (state.relatedBlogs.isNotNullAndNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Constant.horizontalPadding,
                          ),
                          child: Text(
                            'relatedBlogs'.translate(context),
                            style: context.titleMedium,
                          ),
                        ),
                        SizedBox(
                          height: 260,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(
                              horizontal: Constant.horizontalPadding,
                            ),
                            itemCount: state.relatedBlogs.length,
                            separatorBuilder: (_, __) => 10.hGap,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 280,
                                child: BlogItem(
                                  blog: state.relatedBlogs[index],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: Constant.horizontalPadding,
                ),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 2,
                      child: CustomShimmer(borderRadius: 8),
                    ),
                    CustomShimmer(height: 20, width: 300, borderRadius: 8),
                    ...List.generate(20, (index) {
                      return CustomShimmer(
                        height: 10,
                        width: double.maxFinite,
                        borderRadius: 8,
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        ),
    );
  }
}

class _BlogDetails extends StatelessWidget {
  const _BlogDetails({required this.blog});

  final Blog blog;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Constant.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 2,
                child: CustomImage(
                  src: blog.image,
                  fit: BoxFit.cover,
                  radius: 8,
                ),
              ),
              16.vGap,
              BlogCategoryBadge(name: blog.category.name.localized),
              8.vGap,
              Row(
                spacing: 5,
                children: [
                  Icon(AppIcons.eye, size: 16),
                  Text(
                    '${'view'.translate(context)} : ${blog.views}',
                    style: context.bodySmall,
                  ),
                  const SizedBox(height: 10, child: VerticalDivider()),
                  Icon(AppIcons.calendarDots, size: 16),
                  Text(
                    blog.createdAt.format(formatString: 'MMMM dd, yyyy'),
                    style: context.bodySmall,
                  ),
                ],
              ),
              8.vGap,
              Text(blog.title.localized, style: context.titleMedium.semiBold),
              12.vGap,
              HtmlWidget(blog.description.localized),
            ],
          ),
        ),
      ),
    );
  }
}
