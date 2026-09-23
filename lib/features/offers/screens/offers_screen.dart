import 'dart:async';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/features/offers/cubits/offers_cubit.dart';
import 'package:eClassify/features/offers/models/campaign_model.dart';
import 'package:eClassify/features/offers/screens/widgets/offer_item_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => OffersCubit(),
        child: const OffersScreen(),
      ),
    );
  }

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<(String id, String label, IconData icon)> _tabs = [
    ('all', 'All Offers', AppIcons.tagFill),
    ('flash_sale', 'Flash Sales', AppIcons.lightningFill),
    ('deal_of_the_day', 'Daily Deals', AppIcons.clock),
    ('clearance_sale', 'Clearance', AppIcons.tag),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    _loadOffers();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    final selected = _tabs[_tabController.index].$1;
    final loc = AppSession.currentLocation;
    context.read<OffersCubit>().changeTab(
      tab: selected,
      city: loc?.city?.canonical,
      latitude: loc?.latitude,
      longitude: loc?.longitude,
    );
  }

  void _loadOffers() {
    final loc = AppSession.currentLocation;
    context.read<OffersCubit>().fetchOffers(
      tab: _tabs[_tabController.index].$1,
      city: loc?.city?.canonical,
      latitude: loc?.latitude,
      longitude: loc?.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.fireFill, color: Colors.amber, size: 22),
            const SizedBox(width: 8),
            Text('offerZone'.translate(context)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) {
            return Tab(
              child: Row(
                children: [
                  Icon(t.$3, size: 16),
                  const SizedBox(width: 6),
                  Text(t.$2),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadOffers(),
        child: BlocBuilder<OffersCubit, OffersState>(
          builder: (context, state) {
            if (state is OffersLoading) {
              return const Center(child: LoadingIndicator());
            }

            if (state is OffersFailure) {
              return QErrorWidget(
                error: state.errorMessage,
                onRetry: _loadOffers,
              );
            }

            if (state is OffersSuccess) {
              return CustomScrollView(
                slivers: [
                  // Campaign Hero Banner Carousel
                  if (state.campaigns.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: _CampaignHeroSlider(campaigns: state.campaigns),
                      ),
                    ),

                  // Spotlight Ads Section
                  if (state.spotlightAds.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: Row(
                          children: [
                            Icon(AppIcons.sparkleFill, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Spotlight Hot Deals',
                              style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 240,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: state.spotlightAds.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, i) {
                            return SizedBox(
                              width: 180,
                              child: OfferItemCard(item: state.spotlightAds[i]),
                            );
                          },
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],

                  // Main Items Grid
                  if (state.items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(AppIcons.tag, size: 48, color: context.colorScheme.onSurface.withValues(alpha: 0.3)),
                            const SizedBox(height: 12),
                            Text('noPromotionsAvailable'.translate(context)),
                          ],
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => OfferItemCard(item: state.items[i]),
                          childCount: state.items.length,
                        ),
                      ),
                    ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _CampaignHeroSlider extends StatefulWidget {
  const _CampaignHeroSlider({required this.campaigns});

  final List<CampaignModel> campaigns;

  @override
  State<_CampaignHeroSlider> createState() => _CampaignHeroSliderState();
}

class _CampaignHeroSliderState extends State<_CampaignHeroSlider> {
  late final PageController _controller;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.campaigns.length > 1) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final nextPage = (_currentPage + 1) % widget.campaigns.length;
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.campaigns.isEmpty) return const SizedBox.shrink();

    if (widget.campaigns.length == 1) {
      return _CampaignHeroCard(campaign: widget.campaigns.first);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.campaigns.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _CampaignHeroCard(campaign: widget.campaigns[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.campaigns.length, (index) {
            final isSelected = index == _currentPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              width: isSelected ? 20 : 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CampaignHeroCard extends StatefulWidget {
  const _CampaignHeroCard({required this.campaign});

  final CampaignModel campaign;

  @override
  State<_CampaignHeroCard> createState() => _CampaignHeroCardState();
}

class _CampaignHeroCardState extends State<_CampaignHeroCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initTimer();
  }

  @override
  void didUpdateWidget(covariant _CampaignHeroCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.campaign.id != widget.campaign.id) {
      _initTimer();
    }
  }

  void _initTimer() {
    _timer?.cancel();
    _remaining = widget.campaign.endDate.difference(DateTime.now());
    if (!_remaining.isNegative) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        final diff = widget.campaign.endDate.difference(DateTime.now());
        if (diff.isNegative) {
          timer.cancel();
          setState(() {
            _remaining = Duration.zero;
          });
        } else {
          setState(() {
            _remaining = diff;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camp = widget.campaign;
    final days = _remaining.inDays;
    final hours = _remaining.inHours.remainder(24);
    final minutes = _remaining.inMinutes.remainder(60);
    final seconds = _remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            context.colorScheme.primary,
            Colors.amber.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (camp.highlightBadge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          camp.highlightBadge!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      camp.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (camp.description != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        camp.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          // Live Countdown Clock Box
          if (!_remaining.isNegative && _remaining > Duration.zero)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'campaignEndsIn'.translate(context).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTimeTile('$days', 'days'.translate(context)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildTimeTile(hours.toString().padLeft(2, '0'), 'hours'.translate(context)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildTimeTile(minutes.toString().padLeft(2, '0'), 'minutes'.translate(context)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2),
                    child: Text(':', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  _buildTimeTile(seconds.toString().padLeft(2, '0'), 'seconds'.translate(context)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeTile(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 8,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
