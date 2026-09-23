import 'package:eClassify/features/followers/cubits/follow_cubit.dart';
import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/seller/cubits/seller_items_cubit.dart';
import 'package:eClassify/features/seller/screens/seller_live_ads_widget.dart';
import 'package:eClassify/features/seller/screens/seller_profile_header.dart';
import 'package:eClassify/features/seller/screens/seller_ratings_widget.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/deep_link/deep_link_aware_mixin.dart';
import 'package:eClassify/core/deep_link/deep_link_handler.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final int sellerId;

  @override
  _SellerProfileScreenState createState() => _SellerProfileScreenState();

  static Route route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map;
    final reviewCubit = args['review_cubit'] as SellerReviewsCubit?;

    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SellerItemsCubit()),
          if (reviewCubit != null)
            BlocProvider.value(value: reviewCubit)
          else
            BlocProvider(create: (context) => SellerReviewsCubit()),
          BlocProvider(create: (_) => FollowCubit()),
        ],
        child: SellerProfileScreen(sellerId: args['seller_id'] as int),
      ),
    );
  }
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with
        SingleTickerProviderStateMixin,
        DeepLinkAware<SellerProfileScreen, SellerDeepLink> {
  late final TabController _tabController = TabController(
    length: 2,
    vsync: this,
  );

  @override
  DeepLinkHandler<SellerDeepLink> createHandler() {
    return SellerLinkHandler(
      onId: (id) {
        context.read<SellerItemsCubit>().get(reset: true, params: id);
        context.read<SellerReviewsCubit>().get(reset: true, params: id);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (context.read<SellerReviewsCubit>().state is! DataState) {
      context.read<SellerReviewsCubit>().get(
        reset: true,
        params: widget.sellerId,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SellerProfileHeader(
              controller: _tabController,
              sellerId: widget.sellerId,
            ),
          ];
        },
        body: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: TabBarView(
            controller: _tabController,
            children: [
              SellerLiveAdsWidget(sellerId: widget.sellerId),
              SellerRatingsWidget(sellerId: widget.sellerId),
            ],
          ),
        ),
      ),
    );
  }
}
