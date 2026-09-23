import 'package:eClassify/features/category/cubits/category_browsing_cubit.dart';
import 'package:eClassify/features/category/screens/category_view.dart';
import 'package:eClassify/features/category/screens/category_picker.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryFilterScreen extends StatelessWidget {
  const CategoryFilterScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBrowsingCubit(),
        child: const CategoryFilterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('categories'.translate(context))),
      body: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: CategoryPicker(
            mainCategoryMode: CategoryViewMode.list,
            onSelect: (selected, path) {
              // If it's a terminal selection (leaf node), navigate to items list.
              // Note: CategoryPicker's internally handles the drill-down via processCategory.
              // This onSelect is called when CategorySelected state is emitted.
              Navigator.of(context).pop(selected);
            },
          ),
        ),
    );
  }
}
