import 'package:eClassify/features/category/cubits/category_browsing_cubit.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scope that handles BlocListeners for category validation and selection side effects.
class CategoryListenersScope extends StatelessWidget {
  const CategoryListenersScope({
    required this.onSelect,
    required this.child,
    super.key,
  });

  final void Function(Category, List<Category>) onSelect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CategoryBrowsingCubit, CategoryBrowsingState>(
          listener: (context, state) {
            if (state is CategorySelected) {
              LoadingOverlay.hide();
              onSelect(state.categoryTree.last, state.categoryTree);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
