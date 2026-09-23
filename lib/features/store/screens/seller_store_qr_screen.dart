import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/item/screens/widgets/item_card.dart';
import 'package:eClassify/features/store/cubits/seller_store_qr_cubit.dart';
import 'package:eClassify/features/store/models/seller_qr_model.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerStoreQrScreen extends StatefulWidget {
  final String identifier;

  const SellerStoreQrScreen({
    required this.identifier,
    super.key,
  });

  static Route route(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final id = args?['identifier'] as String? ?? '';
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => SellerStoreQrCubit()..fetchStoreCatalog(identifier: id),
        child: SellerStoreQrScreen(identifier: id),
      ),
    );
  }

  @override
  State<SellerStoreQrScreen> createState() => _SellerStoreQrScreenState();
}

class _SellerStoreQrScreenState extends State<SellerStoreQrScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _dismissedWarning = false;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SellerStoreQrCubit>().loadMore();
    }
  }

  void _onSearchSubmit(String query) {
    context.read<SellerStoreQrCubit>().fetchStoreCatalog(
          identifier: widget.identifier,
          search: query.trim().isEmpty ? null : query.trim(),
          categoryId: _selectedCategoryId,
        );
  }

  void _onCategorySelect(int? catId) {
    setState(() => _selectedCategoryId = catId);
    context.read<SellerStoreQrCubit>().fetchStoreCatalog(
          identifier: widget.identifier,
          search: _searchController.text.trim().isEmpty
              ? null
              : _searchController.text.trim(),
          categoryId: catId,
        );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Store Catalog'),
        actions: [
          IconButton(
            icon: const Icon(AppIcons.shareNetwork),
            tooltip: 'Share Store',
            onPressed: () {
              final state = context.read<SellerStoreQrCubit>().state;
              if (state is SellerStoreQrSuccess) {
                final url = state.qrCode?.qrUrl ??
                    'https://bissow.com/store-qr/${widget.identifier}';
                SharePlus.instance.share(
                  ShareParams(
                    text: 'Check out ${state.store.name} on Bissow: $url',
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<SellerStoreQrCubit, SellerStoreQrState>(
        builder: (context, state) {
          if (state is SellerStoreQrLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is SellerStoreQrFailure) {
            return Center(
              child: QErrorWidget(
                error: state.errorMessage,
                onRetry: () {
                  context.read<SellerStoreQrCubit>().fetchStoreCatalog(
                        identifier: widget.identifier,
                      );
                },
              ),
            );
          }

          if (state is SellerStoreQrSuccess) {
            return RefreshIndicator(
              onRefresh: () => context.read<SellerStoreQrCubit>().fetchStoreCatalog(
                    identifier: widget.identifier,
                    search: _searchController.text.trim().isEmpty
                        ? null
                        : _searchController.text.trim(),
                    categoryId: _selectedCategoryId,
                  ),
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 1. Non-blocking Location Discrepancy Alert Banner
                  if (state.locationWarning.warning && !_dismissedWarning)
                    SliverToBoxAdapter(
                      child: _buildLocationWarningBanner(
                        context,
                        state.locationWarning,
                        isDark,
                      ),
                    ),

                  // 2. Store Hero Banner & Header Info
                  SliverToBoxAdapter(
                    child: _buildStoreHeader(context, state.store, isDark),
                  ),

                  // 3. Search & Filter Bar
                  SliverToBoxAdapter(
                    child: _buildSearchAndFilterBar(
                      context,
                      state.categories,
                      state.total,
                    ),
                  ),

                  // 4. Products Grid
                  if (state.items.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                AppIcons.shoppingBagOpen,
                                size: 54,
                                color: context.mutedColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No items found',
                                style: context.bodyLarge.bold,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'No products match your current search or filters.',
                                style: context.bodySmall.withColor(context.mutedColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: 240,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = state.items[index];

                            return ItemCard.grid(
                              item: item,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.adDetailsScreen,
                                  arguments: {
                                    'item_id': item.id,
                                    'preview': item,
                                  },
                                );
                              },
                            );
                          },
                          childCount: state.items.length,
                        ),
                      ),
                    ),

                  // 5. Pagination Loading Indicator
                  if (state.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: LoadingIndicator()),
                      ),
                    ),

                  // 6. Platform Footer Branding
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 40),
                      child: Center(
                        child: Text(
                          'Powered by Bissow.com',
                          style: context.bodySmall.withColor(context.mutedColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLocationWarningBanner(
    BuildContext context,
    LocationWarningModel warning,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF332005) : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF92400E) : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              color: Colors.amber,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Out of Area Seller',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    if (warning.distanceFormatted != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          warning.distanceFormatted!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  warning.message ??
                      'This seller is located in ${warning.storeCity ?? "a different area"}. You can still browse and contact them.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : const Color(0xFF78350F),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.amber,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => setState(() => _dismissedWarning = true),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreHeader(BuildContext context, StoreModel store, bool isDark) {
    final locationText = [store.address, store.city, store.state]
        .where((s) => s != null && s.isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorScheme.surfaceContainerHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          if (store.banner != null && store.banner!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CustomImage(
                src: store.banner!,
                size: const Size(double.infinity, 120),
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo Avatar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 54,
                        height: 54,
                        color: context.colorScheme.primary.withValues(alpha: 0.1),
                        child: store.logo != null && store.logo!.isNotEmpty
                            ? CustomImage(src: store.logo!, fit: BoxFit.cover)
                            : const Icon(AppIcons.storefront, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  store.name,
                                  style: context.bodyLarge.bold,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (store.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ],
                            ],
                          ),
                          if (locationText.isNotEmpty) ...[
                            const SizedBox(height: 3),
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
                                    locationText,
                                    style: context.bodySmall.withColor(context.mutedColor),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Action buttons: Call & Chat
                Row(
                  children: [
                    if (store.contact != null && store.contact!.isNotEmpty)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchUrl('tel:${store.contact}'),
                          icon: const Icon(AppIcons.phone, size: 16),
                          label: const Text('Call Store'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    if (store.contact != null && store.contact!.isNotEmpty)
                      const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.chatScreen,
                            arguments: {
                              'user_id': store.userId,
                              'user_name': store.name,
                              'profile': store.logo,
                            },
                          );
                        },
                        icon: const Icon(AppIcons.chatDots, size: 16),
                        label: const Text('Chat'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar(
    BuildContext context,
    List<Map<String, dynamic>> categories,
    int totalCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Input
          TextField(
            controller: _searchController,
            onSubmitted: _onSearchSubmit,
            decoration: InputDecoration(
              hintText: 'Search items in this store...',
              prefixIcon: const Icon(AppIcons.magnifyingGlass, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchSubmit('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: context.colorScheme.surfaceContainerHigh),
              ),
              filled: true,
              fillColor: context.colorScheme.surface,
            ),
          ),

          // Categories Chips
          if (categories.isNotEmpty) ...[
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All Items'),
                    selected: _selectedCategoryId == null,
                    onSelected: (_) => _onCategorySelect(null),
                  ),
                  const SizedBox(width: 8),
                  ...categories.map((cat) {
                    final catId = cat['id'] as int;
                    final catName = cat['name'] as String? ?? 'Category';
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(catName),
                        selected: _selectedCategoryId == catId,
                        onSelected: (_) => _onCategorySelect(catId),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
