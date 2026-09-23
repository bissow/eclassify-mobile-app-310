import 'package:eClassify/features/blogs/models/blog.dart';
import 'package:eClassify/features/blogs/repository/blogs_repository.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BlogDetailsState {}

class BlogDetailsInitial extends BlogDetailsState {}

class BlogDetailsLoading extends BlogDetailsState {}

class BlogDetailsSuccess extends BlogDetailsState {
  BlogDetailsSuccess({required this.blog, required this.relatedBlogs});

  final Blog blog;
  final List<Blog> relatedBlogs;
}

class BlogDetailsFailure extends BlogDetailsState {
  BlogDetailsFailure({required this.error});

  final Object error;
}

class BlogDetailsCubit extends Cubit<BlogDetailsState> {
  BlogDetailsCubit() : super(BlogDetailsInitial());

  Future<void> getBlogDetails({int? id, String? slug}) async {
    try {
      emit(BlogDetailsLoading());

      final result = await BlogRepository.instance.getBlogDetails(
        id: id,
        slug: slug,
      );

      emit(
        BlogDetailsSuccess(
          blog: result['blog'] as Blog,
          relatedBlogs: result['related'] as List<Blog>,
        ),
      );
    } on Exception catch (e, stack) {
      Log.error(e.toString(), e, stack);
      emit(BlogDetailsFailure(error: e));
    }
  }
}
