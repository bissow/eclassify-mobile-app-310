import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/offers/cubits/seller_promotions_analytics_cubit.dart';
import 'package:eClassify/features/offers/models/seller_promotions_analytics_model.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
import 'package:eClassify/features/verification/models/verification_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerPromotionsScreen extends StatefulWidget {
  const SellerPromotionsScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    final isVerified = AppSession.currentUser?.isVerified ?? false;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => isVerified
            ? (SellerPromotionsAnalyticsCubit()..loadDashboard())
            : SellerPromotionsAnalyticsCubit(),
        child: const SellerPromotionsScreen(),
      ),
    );
  }

  @override
  State<SellerPromotionsScreen> createState() => _SellerPromotionsScreenState();
}

class _SellerPromotionsScreenState extends State<SellerPromotionsScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<({String key, String label})> _filters = [
    (key: 'all', label: 'all'),
    (key: 'sales', label: 'salesAndPromotions'),
    (key: 'boosts', label: 'boostsAndHighlights'),
    (key: 'flash_sale', label: 'flashSale'),
    (key: 'clearance_sale', label: 'clearanceSale'),
    (key: 'deal_of_the_day', label: 'dealOfTheDay'),
    (key: 'daily_bump_up', label: 'dailyBump'),
    (key: 'top_ad', label: 'topAd'),
    (key: 'spotlight', label: 'spotlight'),
  ];


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SellerPromotionsAnalyticsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerified = AppSession.currentUser?.isVerified ?? false;
    if (!isVerified) {
      return Scaffold(
        appBar: AppBar(
          title: Text('promotionsPerformance'.translate(context)),
        ),
        body: _buildVerificationRequiredView(context),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('promotionsPerformance'.translate(context)),
      ),
      body: BlocBuilder<SellerPromotionsAnalyticsCubit, SellerPromotionsAnalyticsState>(
        builder: (context, state) {
          if (state is SellerPromotionsAnalyticsLoading) {
            return const Center(child: LoadingIndicator());
          }

          if (state is SellerPromotionsAnalyticsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(AppIcons.warning, size: 48, color: context.colorScheme.error),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage,
                      textAlign: TextAlign.center,
                      style: context.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<SellerPromotionsAnalyticsCubit>().loadDashboard(),
                      child: Text('retry'.translate(context)),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SellerPromotionsAnalyticsSuccess) {
            return RefreshIndicator(
              onRefresh: () => context.read<SellerPromotionsAnalyticsCubit>().loadDashboard(filter: state.activeFilter),
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  _buildKpiMetrics(context, state.analytics.summary),
                  const SizedBox(height: 20),
                  _buildQuickBreakdown(context, state.analytics),
                  const SizedBox(height: 24),
                  _buildHistoryHeader(context),
                  const SizedBox(height: 10),
                  _buildFilterChips(context, state.activeFilter),
                  const SizedBox(height: 14),
                  _buildHistoryList(context, state),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'promotionsPerformanceDesc'.translate(context),
          style: context.bodySmall.withColor(context.mutedColor),
        ),
      ],
    );
  }

  Widget _buildKpiMetrics(BuildContext context, SellerPromotionsSummary summary) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          title: 'activePromotedAds'.translate(context),
          value: summary.activePromotionsCount.toString(),
          subtitle: ' sales,  boosts',
          icon: AppIcons.fireFill,
          iconColor: Colors.amber.shade700,
          bgColor: Colors.amber.withValues(alpha: 0.1),
        ),
        _MetricCard(
          title: 'unitsSoldOrClaimed'.translate(context),
          value: summary.totalPromotionUnitsSold.toString(),
          subtitle: 'from promo stock',
          icon: AppIcons.shoppingBagOpenFill,
          iconColor: Colors.blue.shade600,
          bgColor: Colors.blue.withValues(alpha: 0.1),
        ),
        _MetricCard(
          title: 'promotionalRevenue'.translate(context),
          value: summary.totalEstimatedPromotionRevenue.toStringAsFixed(2),
          subtitle: 'estimated earnings',
          icon: AppIcons.trendUp,
          iconColor: Colors.green.shade700,
          bgColor: Colors.green.withValues(alpha: 0.1),
        ),
        _MetricCard(
          title: 'buyerSavings'.translate(context),
          value: summary.totalBuyerSavings.toStringAsFixed(2),
          subtitle: 'total discounts',
          icon: AppIcons.tagFill,
          iconColor: Colors.purple.shade600,
          bgColor: Colors.purple.withValues(alpha: 0.1),
        ),
      ],
    );
  }

  Widget _buildQuickBreakdown(BuildContext context, SellerPromotionsAnalyticsModel analytics) {
    final promoMap = analytics.breakdownByPromotionType;
    final boostMap = analytics.breakdownByBoostType;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(AppIcons.trendUp, size: 18, color: context.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'promotionTypesBreakdown'.translate(context),
                style: context.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (promoMap.containsKey('flash_sale'))
                _BreakdownChip(
                  label: 'flashSale'.translate(context),
                  count: promoMap['flash_sale']['active'] ?? 0,
                  icon: AppIcons.lightningFill,
                  color: Colors.red,
                ),
              if (promoMap.containsKey('clearance_sale'))
                _BreakdownChip(
                  label: 'clearanceSale'.translate(context),
                  count: promoMap['clearance_sale']['active'] ?? 0,
                  icon: AppIcons.tagFill,
                  color: Colors.orange,
                ),
              if (promoMap.containsKey('deal_of_the_day'))
                _BreakdownChip(
                  label: 'dealOfTheDay'.translate(context),
                  count: promoMap['deal_of_the_day']['active'] ?? 0,
                  icon: AppIcons.clock,
                  color: Colors.blue,
                ),
              if (boostMap.containsKey('top_ad'))
                _BreakdownChip(
                  label: 'topAd'.translate(context),
                  count: boostMap['top_ad']['active'] ?? 0,
                  icon: AppIcons.fireFill,
                  color: Colors.amber.shade700,
                ),
              if (boostMap.containsKey('spotlight'))
                _BreakdownChip(
                  label: 'spotlight'.translate(context),
                  count: boostMap['spotlight']['active'] ?? 0,
                  icon: AppIcons.sparkleFill,
                  color: Colors.purple,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'promotionHistory'.translate(context),
          style: context.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFilterChips(BuildContext context, String currentFilter) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter.key == currentFilter;
          return FilterChip(
            selected: isSelected,
            label: Text(
              filter.label.translate(context),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? context.colorScheme.onPrimary : context.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selectedColor: context.colorScheme.primary,
            backgroundColor: context.colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant,
              ),
            ),
            onSelected: (_) {
              context.read<SellerPromotionsAnalyticsCubit>().changeFilter(filter.key);
            },
          );
        },

      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, SellerPromotionsAnalyticsSuccess state) {
    if (state.history.isEmpty && !state.isLoadingHistory) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(AppIcons.shoppingBagOpen, size: 40, color: context.mutedColor),
              const SizedBox(height: 8),
              Text(
                'noPromotionsFound'.translate(context),
                style: context.bodyMedium.withColor(context.mutedColor),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ...state.history.map((item) => _HistoryCard(item: item)),
        if (state.isLoadingHistory)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: LoadingIndicator()),
          ),
      ],
    );
  }

  Widget _buildVerificationRequiredView(BuildContext context) {
    final reqState = context.watch<VerificationRequestCubit>().state;
    final request = reqState is VerificationRequestSuccess ? reqState.request : null;
    final isUnderReview = request?.status == VerificationRequestStatus.pending ||
        request?.status == VerificationRequestStatus.resubmitted;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: isUnderReview
                    ? Colors.amber.withValues(alpha: 0.15)
                    : context.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUnderReview ? AppIcons.sealQuestion : AppIcons.shieldCheck,
                size: 44,
                color: isUnderReview ? Colors.amber : context.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isUnderReview ? AppIcons.sealQuestion : AppIcons.sparkleFill,
                    size: 14,
                    color: Colors.amber,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isUnderReview
                        ? 'underReview'.translate(context)
                        : 'verifiedSellersOnly'.translate(context),
                    style: context.labelSmall.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isUnderReview
                  ? 'verificationUnderReviewTitle'.translate(context)
                  : 'verificationRequiredForAnalyticsTitle'.translate(context),
              textAlign: TextAlign.center,
              style: context.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isUnderReview
                  ? 'verificationUnderReviewForAnalyticsDesc'.translate(context)
                  : 'verificationRequiredForAnalyticsDesc'.translate(context),
              textAlign: TextAlign.center,
              style: context.bodyMedium.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: Column(
                children: [
                  _buildBenefitRow(
                    context,
                    AppIcons.checkCircleFill,
                    'verifyBenefitSales'.translate(context),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    context,
                    AppIcons.checkCircleFill,
                    'verifyBenefitClaims'.translate(context),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitRow(
                    context,
                    AppIcons.checkCircleFill,
                    'verifyBenefitBoosts'.translate(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            AppButton(
              title: isUnderReview
                  ? 'checkVerificationStatus'.translate(context)
                  : 'verifyNow'.translate(context),
              variant: AppButtonVariant.filled,
              size: AppButtonSize.normal,
              onPressed: () {
                Navigator.of(context).pushNamed(Routes.verification);
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              title: 'backToMyAds'.translate(context),
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.normal,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: context.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: context.mutedColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, color: context.mutedColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BreakdownChip extends StatelessWidget {
  const _BreakdownChip({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  final String label;
  final int count;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label + ': ',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
          ),
          Text(
            count.toString(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.item});

  final SellerPromotionHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final isSale = item.historyType == 'sale';

    return GestureDetector(
      onTap: () {
        if (item.itemId != null || (item.itemSlug != null && item.itemSlug!.isNotEmpty)) {
          Navigator.pushNamed(
            context,
            Routes.adDetailsScreen,
            arguments: {
              if (item.itemId != null) 'item_id': item.itemId,
              if (item.itemSlug != null && item.itemSlug!.isNotEmpty) 'slug': item.itemSlug,
              'is_my_item': true,
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colorScheme.outlineVariant),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CustomImage(
                  src: item.itemImage,
                  size: const Size(60, 60),
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.titleSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        _buildStatusBadge(context),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _buildTypePill(context),
                    if (item.campaignTitle != null && item.campaignTitle!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'campaign'.translate(context) + ': ' + item.campaignTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: context.mutedColor),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _infoCol(
                context,
                'duration'.translate(context),
                item.activeDurationDays.toString() + ' ' + 'days'.translate(context),
              ),
              if (isSale) ...[
                _infoCol(
                  context,
                  'unitsClaimed'.translate(context),
                  item.unitsClaimed.toString() + ' / ' + item.stockQuantity.toString(),
                ),
                _infoCol(
                  context,
                  'revenue'.translate(context),
                  item.estimatedRevenue.toStringAsFixed(2),
                ),
              ] else ...[
                _infoCol(
                  context,
                  'views'.translate(context),
                  item.views.toString(),
                ),
                _infoCol(
                  context,
                  'status'.translate(context),
                  item.status.toUpperCase(),
                ),
              ],
            ],
          ),
          if (!isSale && item.lastBumpedAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'lastBumped'.translate(context) + ': ' + item.lastBumpedAt!.substring(0, 16).replaceAll('T', ' '),
              style: TextStyle(fontSize: 10, color: Colors.cyan.shade700, fontWeight: FontWeight.w500),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _buildStatusBadge(BuildContext context) {
    final isActive = item.isActive;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isActive ? 'active'.translate(context) : 'ended'.translate(context),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green.shade700 : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildTypePill(BuildContext context) {
    IconData icon;
    Color color;

    if (item.historyType == 'sale') {
      icon = AppIcons.lightningFill;
      color = context.colorScheme.primary;
    } else if (item.type == 'daily_bump_up') {
      icon = AppIcons.arrowsClockwise;
      color = Colors.cyan.shade700;
    } else if (item.type == 'top_ad') {
      icon = AppIcons.fireFill;
      color = Colors.amber.shade800;
    } else {
      icon = AppIcons.sparkleFill;
      color = Colors.purple.shade700;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11,
          color: color,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            item.typeTitle ?? item.type ?? 'Promotion',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
        if (item.discountPercentage != null && item.discountPercentage.toString().isNotEmpty) ...[
          const SizedBox(width: 4),
          Text(
            '(-' + item.discountPercentage.toString() + '%)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.colorScheme.error),
          ),
        ],
      ],
    );
  }

  Widget _infoCol(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: context.mutedColor)),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.bodySmall.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
