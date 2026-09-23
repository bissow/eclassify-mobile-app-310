import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/features/location/cubits/leaf_location_cubit.dart';
import 'package:eClassify/features/store/cubits/store_details_cubit.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreDetailsScreen extends StatefulWidget {
  const StoreDetailsScreen({
    this.slug,
    this.id,
    super.key,
  });

  final String? slug;
  final int? id;

  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (_) => StoreDetailsCubit(),
        child: StoreDetailsScreen(
          slug: args?['slug'] as String?,
          id: args?['id'] as int?,
        ),
      ),
    );
  }

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStoreDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadStoreDetails() {
    final location =
        context.read<LeafLocationCubit>().state ?? AppSession.currentLocation;
    context.read<StoreDetailsCubit>().fetchStoreDetails(
          slug: widget.slug,
          id: widget.id,
          latitude: location?.latitude,
          longitude: location?.longitude,
        );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<StoreDetailsCubit, StoreDetailsState>(
        builder: (context, state) {
          if (state is StoreDetailsLoading) {
            return const Scaffold(
              body: Center(child: LoadingIndicator()),
            );
          }

          if (state is StoreDetailsFailure) {
            return Scaffold(
              appBar: AppBar(),
              body: QErrorWidget(
                error: state.error,
                onRetry: _loadStoreDetails,
              ),
            );
          }

          if (state is StoreDetailsSuccess) {
            final store = state.store;
            final items = state.items;

            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    actions: [
                      CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.5),
                        child: IconButton(
                          icon: const Icon(AppIcons.shareNetwork, color: Colors.white, size: 18),
                          onPressed: () {
                            SharePlus.instance.share(
                              ShareParams(
                                text: '${store.name}\n${store.description ?? ''}',
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (store.banner != null && store.banner!.isNotEmpty)
                            CustomImage(
                              src: store.banner!,
                              fit: BoxFit.cover,
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    context.colorScheme.primary,
                                    context.colorScheme.primary.withValues(alpha: 0.5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  AppIcons.storefront,
                                  size: 64,
                                  color: Colors.white38,
                                ),
                              ),
                            ),
                          // Subtle gradient on banner bottom
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 60,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildStoreHeader(context, store, isDark),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: context.colorScheme.primary,
                        unselectedLabelColor: context.mutedColor,
                        indicatorColor: context.colorScheme.primary,
                        indicatorWeight: 3,
                        tabs: [
                          Tab(
                            text: 'Products (${items.length})',
                          ),
                          const Tab(
                            text: 'About & Hours',
                          ),
                        ],
                      ),
                      color: context.colorScheme.surface,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Products catalog
                  _buildProductsTab(context, items),
                  // Tab 2: About & Operating hours
                  _buildAboutTab(context, store, isDark),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStoreHeader(BuildContext context, StoreModel store, bool isDark) {
    final locationText = [
      if (store.areaName != null && store.areaName!.isNotEmpty) store.areaName,
      if (store.city != null && store.city!.isNotEmpty) store.city,
      if (store.state != null && store.state!.isNotEmpty) store.state,
      if (store.country != null && store.country!.isNotEmpty) store.country,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return Container(
      color: context.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.surface,
                  border: Border.all(
                    color: context.colorScheme.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: store.logo != null && store.logo!.isNotEmpty
                      ? CustomImage(
                          src: store.logo!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: context.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            AppIcons.storefront,
                            size: 32,
                            color: context.colorScheme.primary,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 14),
              // Store Title & Verification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            store.name,
                            style: context.bodyLarge.bold.copyWith(fontSize: 18),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (store.isVerified) ...[
                          const SizedBox(width: 6),
                          Icon(
                            AppIcons.sealCheckFill,
                            color: context.colorScheme.primary,
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Rating & distance
                    Row(
                      children: [
                        const Icon(AppIcons.starFill, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          (store.stats?.averageRating ?? 0.0).toStringAsFixed(1),
                          style: context.bodySmall.semiBold,
                        ),
                        if ((store.stats?.totalReviews ?? 0) > 0)
                          Text(
                            ' (${store.stats!.totalReviews})',
                            style: context.bodySmall.withColor(context.mutedColor),
                          ),
                        if (store.distance != null && store.distance!.formatted.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text('•', style: TextStyle(color: context.mutedColor)),
                          const SizedBox(width: 8),
                          Icon(
                            AppIcons.mapPinFill,
                            size: 13,
                            color: context.colorScheme.primary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            store.distance!.formatted,
                            style: context.bodySmall.semiBold.copyWith(
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Address
                    Row(
                      children: [
                        Icon(
                          AppIcons.mapPin,
                          size: 13,
                          color: context.mutedColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            locationText.isNotEmpty ? locationText : (store.address ?? ''),
                            style: context.bodySmall.withColor(context.mutedColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action Buttons: Call, Email, Website
          Row(
            children: [
              if (store.contact != null && store.contact!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl('tel:${store.countryCode ?? ''}${store.contact}'),
                    icon: const Icon(AppIcons.phone, size: 16),
                    label: const Text('Call'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              if (store.contact != null && store.contact!.isNotEmpty)
                const SizedBox(width: 8),
              if (store.email != null && store.email!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl('mailto:${store.email}'),
                    icon: const Icon(AppIcons.envelopeSimple, size: 16),
                    label: const Text('Email'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              if (store.email != null && store.email!.isNotEmpty)
                const SizedBox(width: 8),
              if (store.website != null && store.website!.isNotEmpty)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _launchUrl(
                      store.website!.startsWith('http') ? store.website! : 'https://${store.website!}',
                    ),
                    icon: const Icon(AppIcons.globe, size: 16),
                    label: const Text('Website'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(BuildContext context, List<dynamic> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                AppIcons.shoppingBagOpen,
                size: 56,
                color: context.mutedColor.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              Text(
                'No products listed yet',
                style: context.bodyLarge.bold,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 240,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final preview = ItemPreview(
          id: item.id as int,
          userId: item.seller?.id as int? ?? 0,
          image: item.image as String? ?? '',
          price: item.price as String?,
          name: item.name?.localized ?? item.name?.canonical ?? '',
          address: item.address?.localized ?? item.address?.canonical ?? '',
          postedAt: DateTime.now(),
        );

        return ItemCard.grid(
          item: preview,
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.adDetailsScreen,
              arguments: {'item_id': item.id, 'preview': preview},
            );
          },
        );
      },
    );
  }

  Widget _buildAboutTab(BuildContext context, StoreModel store, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store Description
          if (store.description != null && store.description!.isNotEmpty) ...[
            Text(
              'About Store',
              style: context.bodyLarge.bold,
            ),
            const SizedBox(height: 8),
            Text(
              store.description!,
              style: context.bodyMedium.copyWith(
                color: context.mutedColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),
          ],
          // Operating Hours
          Text(
            'Operating Hours',
            style: context.bodyLarge.bold,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(AppIcons.clock, size: 16),
                        const SizedBox(width: 8),
                        Text('Hours', style: context.bodyMedium.semiBold),
                      ],
                    ),
                    Text(
                      store.openingTime != null && store.closingTime != null
                          ? '${store.openingTime} - ${store.closingTime}'
                          : 'Open 24/7',
                      style: context.bodyMedium,
                    ),
                  ],
                ),
                if (store.workingDays != null && store.workingDays!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(AppIcons.calendarDots, size: 16),
                          const SizedBox(width: 8),
                          Text('Days', style: context.bodyMedium.semiBold),
                        ],
                      ),
                      Flexible(
                        child: Text(
                          store.workingDays!.join(', '),
                          textAlign: TextAlign.end,
                          style: context.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          // Additional Info
          Text(
            'Store Information',
            style: context.bodyLarge.bold,
          ),
          const SizedBox(height: 12),
          if (store.taxNumber != null && store.taxNumber!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: AppIcons.receipt,
              label: 'Tax / VAT Number',
              value: store.taxNumber!,
            ),
          if (store.address != null && store.address!.isNotEmpty)
            _buildInfoTile(
              context,
              icon: AppIcons.mapPin,
              label: 'Address',
              value: store.address!,
            ),
          if (store.owner != null)
            _buildInfoTile(
              context,
              icon: AppIcons.user,
              label: 'Owner / Manager',
              value: store.owner!.name,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: context.colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: context.bodySmall.withColor(context.mutedColor),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: context.bodyMedium.semiBold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {required this.color});

  final TabBar _tabBar;
  final Color color;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: color,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
