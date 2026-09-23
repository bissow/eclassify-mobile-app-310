import 'dart:async';

import 'package:eClassify/app/widgets/bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:eClassify/app/widgets/session_end_listener.dart';
import 'package:eClassify/app/widgets/version_update_dialog.dart';
import 'package:eClassify/core/cubits/app_update_cubit.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/core/deep_link/deep_link_listener.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/features/chat/screens/inbox/chat_list_screen.dart';
import 'package:eClassify/features/home/screens/home_screen.dart';
import 'package:eClassify/features/notification/listeners/notification_provider.dart';
import 'package:eClassify/features/profile/screens/profile_tab_screen.dart';
import 'package:eClassify/features/reels/screens/video_ads_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) =>
          NotificationProvider(child: DeepLinkListener(child: MainScreen())),
    );
  }
}

class MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    context.read<AppUpdateCubit>().checkForUpdates();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (context.read<BottomNavCubit>().state.activeTab != BottomTab.home) {
          context.read<BottomNavCubit>().changeTab(BottomTab.home);
        } else {
          if (_timer == null) {
            _timer = Timer(const Duration(seconds: 2), () {
              _timer?.cancel();
              _timer = null;
            });
            HelperUtils.showSnackBarMessage(
              context,
              "pressAgainToExit".translate(context),
            );
          } else {
            SystemNavigator.pop();
          }
        }
      },
      // Plain Scaffold on purpose: this is the tab shell, not a screen. It
      // only hosts the shared nav bar; each tab is its own AppScaffold and
      // adds the resting gap once, so the shell must not add another.
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        extendBody: true,
        bottomNavigationBar: CustomBottomNavigationBar(),
        body: SessionEndListener(
          child: MultiBlocListener(
            listeners: [
              BlocListener<AppUpdateCubit, AppUpdateState>(
                listener: (context, state) {
                  // Mandatory updates are already handled in SplashScreen,
                  // before MainScreen ever mounts. Only optional updates
                  // reach here.
                  if (state is AppUpdateAvailable && !state.isMandatory) {
                    VersionUpdateDialog.show(
                      context,
                      availableVersion: state.required,
                      isForceUpdate: state.isMandatory,
                    );
                  }
                },
              ),
              BlocListener<BottomNavCubit, BottomNavState>(
                listener: (context, state) {
                  _pageController.jumpToPage(state.activeTab.index);
                },
              ),
            ],
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const HomeScreen(),
                const ChatListScreen(),
                const VideoAdsScreen(),
                const ProfileTabScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
