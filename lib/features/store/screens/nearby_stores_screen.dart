import 'dart:async';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/features/location/cubits/leaf_location_cubit.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/store/cubits/nearby_stores_cubit.dart';
import 'package:eClassify/features/store/screens/widgets/store_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NearbyStoresScreen extends StatefulWidget {
  const NearbyStoresScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (_) => NearbyStoresCubit(),
        child: const NearbyStoresScreen(),
      ),
    );
  }

  @override
  State<NearbyStoresScreen> createState() => _NearbyStoresScreenState();
}

class _NearbyStoresScreenState extends State<NearbyStoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  num _selectedRadius = 25;
  String _selectedSort = 'distance_asc';

  final List<num> _radiusOptions = [5, 10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    final initialLocation =
        context.read<LeafLocationCubit>().state ?? AppSession.currentLocation;
    _fetchStores(location: initialLocation);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<NearbyStoresCubit>().fetchMoreStores();
    }
  }

  void _fetchStores({LeafLocation? location}) {
    final effectiveLocation = location ??
        context.read<LeafLocationCubit>().state ??
        AppSession.currentLocation;

    context.read<NearbyStoresCubit>().fetchStores(
          location: effectiveLocation,
          radius: _selectedRadius,
          search: _searchController.text.trim(),
          sortBy: _selectedSort,
        );
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _fetchStores();
    });
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.pushNamed(context, Routes.locationScreen)
        as LeafLocation?;
    if (result != null && mounted) {
      context.read<LeafLocationCubit>().setLocation(result);
      _fetchStores(location: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('nearbyStores'.translate(context)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Centralized Location & Search Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location Bar Button
                GestureDetector(
                  onTap: _pickLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.mapPinFill,
                          color: context.colorScheme.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: BlocBuilder<LeafLocationCubit, LeafLocation?>(
                            builder: (context, location) {
                              final loc = location ?? AppSession.currentLocation;
                              return Text(
                                loc?.primaryText ?? 'location'.translate(context),
                                style: context.bodyMedium.semiBold,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                        ),
                        Icon(
                          AppIcons.caretRight,
                          size: 16,
                          color: context.mutedColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'search'.translate(context),
                    hintStyle: context.bodySmall.withColor(context.mutedColor),
                    prefixIcon: const Icon(AppIcons.magnifyingGlass, size: 18),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(AppIcons.x, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _fetchStores();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.1),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Radius Filter Chips
                Row(
                  children: [
                    Text(
                      'Radius:',
                      style: context.bodySmall.semiBold,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _radiusOptions.map((r) {
                            final isSelected = _selectedRadius == r;
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text('${r} km'),
                                selected: isSelected,
                                selectedColor: context.colorScheme.primary,
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.white
                                      : context.mutedColor,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedRadius = r;
                                    });
                                    _fetchStores();
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Stores List Body
          Expanded(
            child: BlocBuilder<NearbyStoresCubit, NearbyStoresState>(
              builder: (context, state) {
                if (state is NearbyStoresLoading) {
                  return const Center(
                    child: LoadingIndicator(),
                  );
                }

                if (state is NearbyStoresFailure) {
                  return QErrorWidget(
                    error: state.error,
                    onRetry: () => _fetchStores(),
                  );
                }

                if (state is NearbyStoresSuccess) {
                  if (state.stores.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              AppIcons.storefront,
                              size: 64,
                              color: context.mutedColor.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'noStoresFound'.translate(context),
                              style: context.bodyLarge.bold,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search radius or changing location.',
                              textAlign: TextAlign.center,
                              style: context.bodySmall.withColor(context.mutedColor),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _pickLocation,
                              icon: const Icon(AppIcons.mapPin, size: 18),
                              label: Text('location'.translate(context)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _fetchStores(),
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.stores.length + (state.isPageLoading ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        if (index == state.stores.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: LoadingIndicator()),
                          );
                        }

                        final store = state.stores[index];
                        return StoreCard(store: store);
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
