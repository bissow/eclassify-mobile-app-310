import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/deep_link/deep_link_aware_mixin.dart';
import 'package:eClassify/core/deep_link/deep_link_handler.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/utils/share_utility.dart';
import 'package:eClassify/core/utils/tap_guard.dart';
import 'package:eClassify/core/widgets/ads/google_banner_ad.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/features/advertisement/cubits/create_featured_ad_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/fetch_item_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/item_report_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/related_items_cubit.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/admin_edited_card.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/custom_fields_widget.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/detail_banner_ad_widget.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/feature_ad_card.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_actions/item_action_widget.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_actions/seller_item_menu.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_basic_details.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_description_widget.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_location_map.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_statistics_widget.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/item_status_widget.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/media_gallery_view/media_gallery_widget.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/related_items_list.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/report_ad/report_ad_card.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/seller_profile/seller_profile_card.dart';
import 'package:eClassify/features/banner/cubits/banner_ad_cubit.dart';
import 'package:eClassify/features/banner/models/banner_ad.dart';
import 'package:eClassify/features/chat/cubits/item_offer_cubit.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/item/extensions/item_extension.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/models/my_item.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdDetailsScreen extends StatefulWidget {
  const AdDetailsScreen({
    this.preview,
    this.slug,
    this.itemId,
    this.isMyItem = false,
    super.key,
  }) : assert(
         slug != null || itemId != null || preview != null,
         'Either slug, itemId or preview must be provided.',
       );

  final ItemPreview? preview;
  final String? slug;
  final int? itemId;
  final bool? isMyItem;

  @override
  State<AdDetailsScreen> createState() => _AdDetailsScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    final preview = args?['preview'] as ItemPreview?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => FetchItemCubit()),
          BlocProvider(create: (_) => CreateFeaturedAdCubit()),
          BlocProvider(create: (_) => ItemReportCubit()),
          BlocProvider(create: (_) => RelatedItemsCubit()),
          BlocProvider(create: (_) => ItemOfferCubit()),
          BlocProvider(create: (_) => DetailBannerAdCubit()),
          BlocProvider(create: (_) => SellerReviewsCubit()),
        ],
        child: AdDetailsScreen(
          preview: preview,
          slug: args?['slug'] as String?,
          itemId: args?['item_id'] as int? ?? preview?.id,
          isMyItem: args?['is_my_item'] as bool?,
        ),
      ),
    );
  }
}

class _AdDetailsScreenState extends State<AdDetailsScreen>
    with DeepLinkAware<AdDetailsScreen, ItemDeepLink> {
  Item? item;

  MyItem? get myItem => item is MyItem ? item as MyItem : null;

  bool? get isMyAd => widget.isMyItem ?? widget.preview?.isMyAd;

  bool didUpdate = false;
  bool _hasFetchedOnce = false;

  final TapGuard _tapGuard = TapGuard();

  @override
  DeepLinkHandler<ItemDeepLink> createHandler() {
    return ItemLinkHandler(
      onSlug: (slug) {
        if (slug != item?.slug) {
          Navigator.of(context).pushReplacementNamed(
            Routes.adDetailsScreen,
            arguments: {'slug': slug},
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchItem();
  }

  void _fetchItem() {
    context.read<FetchItemCubit>().fetchItem(
      itemId: widget.itemId,
      slug: widget.slug,
      isMyAd: isMyAd ?? false,
    );
    context.read<DetailBannerAdCubit>().fetchBanners();
  }

  Widget _divider() {
    if (item == null) return const SizedBox.shrink();
    return Divider(
      indent: Constant.horizontalPadding,
      endIndent: Constant.horizontalPadding,
      height: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchItemCubit, FetchItemState>(
      listener: (context, state) {
        if (state is! FetchItemSuccess) return;
        if (!_hasFetchedOnce) {
          _hasFetchedOnce = true;
          return;
        }
        didUpdate = true;
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          Navigator.of(context).pop(didUpdate);
        },
        child: AppScaffold(
          backgroundColor: context.colorScheme.secondary,
          appBar: AppBar(
            actions: [
              BlocBuilder<FetchItemCubit, FetchItemState>(
                builder: (context, state) {
                  if (item == null) return const SizedBox.shrink();
                  if (item case MyItem item
                      when item.status != ItemStatus.approved) {
                    return const SizedBox.shrink();
                  }
                  return IconButton(
                    onPressed: () {
                      if (item == null) return;
                      _tapGuard.run(() async {
                        ShareUtility.share(context, ItemDeepLink(item!.slug));
                      });
                    },
                    icon: Icon(AppIcons.shareNetwork, size: 24),
                  );
                },
              ),
              SellerItemMenu(),
            ],
          ),
          bottomNavigationBar: const ItemActionWidget(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.symmetric(vertical: 12),
            child: BlocBuilder<FetchItemCubit, FetchItemState>(
              builder: (context, state) {
                if (state is FetchItemFailure) {
                  return QErrorWidget(error: state.error, onRetry: _fetchItem);
                }

                // Keep showing the previous item while a refetch is in flight
                // (e.g. after popping back from edit) instead of nulling it out
                // on FetchItemLoading — otherwise every conditional child below
                // briefly drops out of the list, shifting unkeyed siblings by
                // index and forcing Flutter to tear down/rebuild them (this is
                // what caused the GoogleMap "used after disposed" crash).
                if (state is FetchItemSuccess) item = state.item;
                final isMyAd = this.isMyAd ?? item?.isMyAd ?? false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const DetailBannerAdWidget(
                      section: DetailSection.image,
                      placement: BannerPlacement.above,
                    ),
                    MediaGalleryWidget(
                      previewImage: widget.preview?.image,
                      item: item,
                    ),
                    const DetailBannerAdWidget(
                      section: DetailSection.image,
                      placement: BannerPlacement.below,
                    ),
                    if (isMyAd)
                      ItemStatisticsWidget(
                        views: myItem?.totalViews ?? 0,
                        likes: myItem?.totalLikes ?? 0,
                      ),
                    if (isMyAd &&
                        (myItem?.adminEditReason).isNotNullAndNotEmpty)
                      AdminEditedCard(reason: myItem!.adminEditReason!),
                    if (isMyAd && myItem != null && myItem!.isRejected)
                      ItemStatusWidget(item: myItem!),
                    const DetailBannerAdWidget(
                      section: DetailSection.adInfo,
                      placement: BannerPlacement.above,
                    ),
                    ItemBasicDetails(preview: widget.preview, item: item),
                    _divider(),
                    if (Constant.systemSettings.isBannerAdEnabled && !isMyAd)
                      GoogleBannerAd(),
                    if (isMyAd &&
                        !(myItem?.isFeatured ?? item?.isFeatured ?? true) &&
                        (myItem == null || myItem?.status == ItemStatus.approved))
                      FeatureAdCard(
                        itemId: myItem?.id ?? item!.id,
                        price: double.tryParse(item?.price?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '') ?? 0.0,
                      ),
                    if ((item?.customFields).isNotNullAndNotEmpty)
                      CustomFieldsWidget(fields: item!.customFieldsByFieldId),
                    const DetailBannerAdWidget(
                      section: DetailSection.adInfo,
                      placement: BannerPlacement.below,
                    ),
                    _divider(),
                    const DetailBannerAdWidget(
                      section: DetailSection.aboutAd,
                      placement: BannerPlacement.above,
                    ),
                    ItemDescriptionWidget(
                      description: item?.description.localized,
                    ),
                    _divider(),
                    if (!isMyAd)
                      SellerProfileCard(
                        seller: item?.seller,
                        contact: item?.contact,
                        itemName: item?.name.localized,
                        itemSlug: item?.slug,
                      ),
                    const DetailBannerAdWidget(
                      section: DetailSection.aboutAd,
                      placement: BannerPlacement.below,
                    ),
                    _divider(),
                    const DetailBannerAdWidget(
                      section: DetailSection.location,
                      placement: BannerPlacement.above,
                    ),
                    ItemLocationMap(coordinates: item?.coordinates),
                    const DetailBannerAdWidget(
                      section: DetailSection.location,
                      placement: BannerPlacement.below,
                    ),
                    if (Constant.systemSettings.isBannerAdEnabled && !isMyAd)
                      GoogleBannerAd(),
                    const DetailBannerAdWidget(
                      section: DetailSection.similarAds,
                      placement: BannerPlacement.above,
                    ),
                    if (!isMyAd && !(item?.hasAlreadyReported ?? true))
                      ReportAdCard(
                        itemId: item!.id,
                        isReported: item!.hasAlreadyReported,
                      ),
                    if (!isMyAd)
                      RelatedItemsList(
                        categoryId: item?.category.id,
                        itemId: item?.id,
                      ),
                    const DetailBannerAdWidget(
                      section: DetailSection.similarAds,
                      placement: BannerPlacement.below,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
