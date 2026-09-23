import 'package:eClassify/features/review/cubits/purchased_items_cubit.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/review/screens/widgets/my_reviews_list.dart';
import 'package:eClassify/features/review/screens/widgets/purchased_item_list.dart';
import 'package:eClassify/core/widgets/layout/app_tab_bar.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => MyReviewsCubit()),
          BlocProvider(create: (_) => PurchasedItemsCubit()),
        ],
        child: const ReviewScreen(),
      ),
    );
  }

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text('reviews'.translate(context)),
        bottom: AppTabBar(
          controller: _tabController,
          tabs: ['received', 'given'],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [const MyReviewsList(), const PurchasedItemList()],
      ),
    );
  }
}
