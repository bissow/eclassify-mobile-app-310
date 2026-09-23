import 'dart:io';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/features/category/cubits/category_browsing_cubit.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/features/category/screens/category_picker.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryBrowsingScreen extends StatelessWidget {
  const CategoryBrowsingScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    final initialCategory = routeSettings.arguments as Category?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => CategoryBrowsingCubit(initialPath: [?initialCategory]),
        child: CategoryBrowsingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pathNotifier = context.read<CategoryBrowsingCubit>().pathNotifier;
    return PopScope(
      canPop: !Platform.isAndroid,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (pathNotifier.isNotEmpty) {
          context.read<CategoryBrowsingCubit>().navigateBackTo(
            pathNotifier.last,
          );
          return;
        } else {
          Navigator.of(context).pop();
        }
      },
      child: AppScaffold(
        appBar: AppBar(title: Text('categories'.translate(context))),
        body: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: CategoryPicker(
            onSelect: (selected, path) {
              // If it's a terminal selection (leaf node), navigate to items list.
              // Note: CategoryPicker's internally handles the drill-down via processCategory.
              // This onSelect is called when CategorySelected state is emitted.
              Navigator.of(context).pushNamed(
                Routes.itemsList,
                arguments: CategoryMetaData(category: selected),
              );
            },
          ),
        ),
      ),
    );
  }
}
