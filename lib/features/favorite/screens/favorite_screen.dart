import 'package:cached_network_image/cached_network_image.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/features/favorite/cubits/favorite_items_cubit.dart';
import 'package:eClassify/features/item/models/ad_item_type.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/features/reels/cubits/liked_reels_cubit.dart';
import 'package:eClassify/features/reels/models/video_ad.dart';
import 'package:eClassify/core/widgets/layout/app_tab_bar.dart';
import 'package:eClassify/core/widgets/layout/paginated_view/paginated_view.dart';
import 'package:eClassify/features/item/screens/widgets/featured_badge.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/ads/interstitial_ad_on_exit_mixin.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return BlocProvider(
          create: (context) => FavoriteItemsCubit(),
          child: const FavoriteScreen(),
        );
      },
    );
  }

  @override
  FavoriteScreenState createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen>
    with InterstitialAdOnExitMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text("favorites".translate(context)),
        bottom: AppTabBar(
          controller: _tabController,
          tabs: AdItemType.values
              .map((type) => type.label.translate(context))
              .toList(),
        ),
      ),
      body: TabBarView(
          controller: _tabController,
          children: const [FavoriteItemsWidget(), LikedReelsWidget()],
        ),
    );
  }
}

class FavoriteItemsWidget extends StatefulWidget {
  const FavoriteItemsWidget({super.key});

  @override
  State<FavoriteItemsWidget> createState() => _FavoriteItemsWidgetState();
}

class _FavoriteItemsWidgetState extends State<FavoriteItemsWidget> {
  @override
  Widget build(BuildContext context) {
    return PaginatedListView<FavoriteItemsCubit, ItemPreview, void>(
      padding: context.bodyPadding(),
      itemBuilder: (context, item) => ItemCard.list(item: item),
      separatorBuilder: (_, _) => 8.vGap,
    );
  }
}

class LikedReelsWidget extends StatefulWidget {
  const LikedReelsWidget({super.key});

  @override
  State<LikedReelsWidget> createState() => _LikedReelsWidgetState();
}

class _LikedReelsWidgetState extends State<LikedReelsWidget> {
  @override
  Widget build(BuildContext context) {
    return PaginatedGridView<LikedReelsCubit, VideoAd, void>(
      padding: context.bodyPadding(),
      itemBuilder: (context, ad) => _VideoAdThumbnail(ad: ad),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
    );
  }
}

class _VideoAdThumbnail extends StatelessWidget {
  const _VideoAdThumbnail({required this.ad});

  final VideoAd ad;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: CachedNetworkImageProvider(ad.thumbnail),
          fit: BoxFit.cover,
        ),
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.videoAdsScreen,
            arguments: {'reel_id': ad.id},
          );
        },
        child: Stack(
          children: [
            PositionedDirectional(
              top: 8,
              end: 8,
              start: 8,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [if (ad.item.isFeatured) FeaturedBadge()],
              ),
            ),
            PositionedDirectional(
              end: 8,
              start: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ad.item.name,
                    maxLines: 1,
                    style: context.titleMedium.withColor(Colors.white),
                  ),
                  if (ad.item.price.isNotNullAndNotEmpty)
                    Text(
                      ad.item.price!,
                      maxLines: 1,
                      style: context.titleMedium.withColor(Colors.white),
                    ),
                  Text(
                    ad.item.address,
                    maxLines: 1,
                    style: context.titleMedium.withColor(Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
