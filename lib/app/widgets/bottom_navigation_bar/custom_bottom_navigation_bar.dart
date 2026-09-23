import 'package:eClassify/app/widgets/bottom_navigation_bar/app_fab.dart';
import 'package:eClassify/app/widgets/bottom_navigation_bar/blob_border.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/chat/cubits/chat_list_cubit.dart';
import 'package:eClassify/features/chat/cubits/seller_item_offers_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Custom Navigation bar that gives space to the centerDocked FAB button
class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();

  static double height(BuildContext context) =>
      kBottomNavigationBarHeight + MediaQuery.paddingOf(context).bottom;
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    value: 1.0,
  );

  late final Animation<Offset> _slideAnimation = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  final items = [
    _BottomNavigationItem(
      tab: BottomTab.home,
      icon: AppAssets.bottomNavigation.home,
      activeIcon: AppAssets.bottomNavigation.homeActive,
      label: 'homeTab',
    ),
    _BottomNavigationItem(
      tab: BottomTab.chat,
      icon: AppAssets.bottomNavigation.chat,
      activeIcon: AppAssets.bottomNavigation.chatActive,
      label: 'chat',
    ),
    // For accommodating FAB
    null,
    _BottomNavigationItem(
      tab: BottomTab.videoAds,
      icon: AppAssets.bottomNavigation.videoAds,
      activeIcon: AppAssets.bottomNavigation.videoAdsActive,
      label: 'videoAd',
    ),
    _BottomNavigationItem(
      tab: BottomTab.profile,
      icon: AppAssets.bottomNavigation.profile,
      activeIcon: AppAssets.bottomNavigation.profileActive,
      label: 'profileTab',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BottomNavCubit, BottomNavState>(
      listenWhen: (previous, current) =>
          previous.isVisible != current.isVisible,
      listener: (context, state) {
        if (state.isVisible) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      },
      child: SlideTransition(
        position: _slideAnimation,
        child: ColoredBox(
          color: context.colorScheme.secondary,
          child: SafeArea(
            child: Padding(
              padding: Constant.pagePadding.copyWith(
                bottom: Constant.verticalPadding,
              ),
              child: SizedBox(
                height: kBottomNavigationBarHeight,
                child: BlocBuilder<BottomNavCubit, BottomNavState>(
                  builder: (context, state) {
                    return Row(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: items.map((item) {
                        if (item == null) {
                          return AppFab(
                            type: FabType.custom,
                            border: BlobBorderShape(),
                          );
                        }
                        Widget child = _BottomNavigationItemWidget(
                          item: item,
                          selected: state.activeTab == item.tab,
                          onPressed: () {
                            HapticFeedback.vibrate();
                            if (item.tab case == BottomTab.chat) {
                              UiUtils.checkUser(
                                onNotGuest: () {
                                  context.read<BottomNavCubit>().changeTab(
                                    item.tab,
                                  );
                                },
                                context: context,
                              );
                            } else {
                              context.read<BottomNavCubit>().changeTab(
                                item.tab,
                              );
                            }
                          },
                        );
                        if (item.tab == BottomTab.chat) {
                          child = _DynamicChatIconWithBadge(child: child);
                        }
                        return Expanded(child: child);
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavigationItemWidget extends StatelessWidget {
  _BottomNavigationItemWidget({
    required this.item,
    required this.selected,
    required this.onPressed,
  });

  final _BottomNavigationItem item;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 4,
        children: [
          CustomImage(
            src: selected ? item.activeIcon : item.icon,
            size: Size.square(20),
            fit: BoxFit.contain,
          ),
          Text(
            item.label.translate(context),
            textAlign: TextAlign.center,
            maxLines: 1,
            style: context.labelMedium.withColor(
              selected ? context.colorScheme.onSurface : context.mutedColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationItem {
  _BottomNavigationItem({
    required this.tab,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final BottomTab tab;
  final String icon;
  final String activeIcon;
  final String label;
}

class _DynamicChatIconWithBadge extends StatelessWidget {
  const _DynamicChatIconWithBadge({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sellerCount = context.select<SellerItemOffersCubit, int>((
      offerCubit,
    ) {
      return switch (offerCubit.state) {
        final SellerItemOffersSuccess s when s.offers.isNotEmpty =>
          s.offers.fold(0, (value, ele) => value + ele.unreadCount),
        _ => 0,
      };
    });

    final buyerCount = context.select<BuyingChatListCubit, int>((buyingCubit) {
      return switch (buyingCubit.state) {
        final ChatListSuccess b when b.users.isNotEmpty => b.users.fold(
          0,
          (value, ele) => value + ele.unreadCount,
        ),
        _ => 0,
      };
    });

    final totalUnread = sellerCount + buyerCount;
    final label = totalUnread.compact;

    return switch (totalUnread) {
      > 0 => Badge(
        alignment: AlignmentDirectional.topCenter.add(
          AlignmentGeometry.directional(.1, 0),
        ),
        backgroundColor: context.colorScheme.tertiary,
        label: Text(
          label,
          style: context.labelSmall.withColor(context.colorScheme.onPrimary),
        ),
        child: child,
      ),
      _ => child,
    };
  }
}
