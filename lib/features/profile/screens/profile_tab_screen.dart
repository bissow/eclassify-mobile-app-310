import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/app/widgets/bottom_navigation_bar/custom_bottom_navigation_bar.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/cubits/app_theme_cubit.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/share_utility.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/features/auth/cubits/delete_account_cubit.dart';
import 'package:eClassify/features/auth/cubits/logout_cubit.dart';
import 'package:eClassify/features/auth/ui/modals/delete_account_dialog.dart';
import 'package:eClassify/features/auth/ui/modals/logout_dialog.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/features/profile/models/menu_item.dart';
import 'package:eClassify/features/profile/models/menu_item_action.dart';
import 'package:eClassify/features/profile/models/menu_section.dart';
import 'package:eClassify/features/profile/screens/widgets/menu_section_widget.dart';
import 'package:eClassify/features/profile/screens/widgets/my_activity_section.dart';
import 'package:eClassify/features/profile/screens/widgets/profile_header.dart';
import 'package:eClassify/features/profile/screens/widgets/profile_listeners_scope.dart';
import 'package:eClassify/features/profile/screens/widgets/user_verification_card.dart';
import 'package:eClassify/features/subscription/cubits/active_subscription_package_cubit.dart';
import 'package:eClassify/features/user_profile/cubits/user_profile_cubit.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with AutomaticKeepAliveClientMixin<ProfileTabScreen> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    context.watch<AuthSessionCubit>();
    final isAuthenticated = AppSession.isAuthenticated;
    final showLanguageMenu = Constant.systemSettings.languages.length > 1;

    final menuSections = [
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.sketchLogo,
            title: 'subscription',
            action: CustomAction(
              onTap: () async {
                if (isAuthenticated) {
                  context.read<ActiveSubscriptionPackageCubit>().getPackages();
                } else {
                  Navigator.pushNamed(context, Routes.subscriptionScreen);
                }
              },
            ),
          ),
          MenuItem(
            icon: AppIcons.clockCounterClockwise,
            title: 'transactionHistory',
            action: ScreenPushAction(
              route: Routes.transactionHistory,
              guarded: true,
            ),
          ),
          MenuItem(
            icon: AppIcons.trendUp,
            title: 'reviews',
            action: ScreenPushAction(route: Routes.reviewScreen, guarded: true),
          ),
        ],
      ),
      MenuSection(
        items: [
          if (showLanguageMenu)
            MenuItem(
              icon: AppIcons.translate,
              title: 'language',
              action: ScreenPushAction(route: Routes.languageListScreen),
            ),
          MenuItem(
            icon: AppIcons.moon,
            title: 'darkTheme',
            showTrailing: true,
            action: CustomAction(
              onTap: () async {
                context.read<AppThemeCubit>().toggleTheme();
              },
            ),
            trailing: BlocBuilder<AppThemeCubit, ThemeMode>(
              builder: (context, theme) {
                return Switch(
                  value: theme == ThemeMode.dark,
                  onChanged: (value) {
                    context.read<AppThemeCubit>().toggleTheme();
                  },
                );
              },
            ),
          ),
          MenuItem(
            icon: AppIcons.bell,
            title: 'notifications',
            action: ScreenPushAction(
              route: Routes.notificationListScreen,
              guarded: true,
            ),
          ),
        ],
      ),
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.star,
            title: 'rateUs',
            action: CustomAction(onTap: () async => rateUs()),
          ),
          MenuItem(
            icon: AppIcons.shareNetwork,
            title: 'shareApp',
            action: CustomAction(
              onTap: () async {
                await shareApp(context);
              },
            ),
          ),
        ],
      ),
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.article,
            title: 'blogs',
            action: ScreenPushAction(route: Routes.blogsScreen),
          ),
          MenuItem(
            icon: AppIcons.headset,
            title: 'helpAndSupport',
            showTrailing: true,
            action: ScreenPushAction(route: Routes.helpAndSupportScreen),
          ),
        ],
      ),
      MenuSection(
        items: [
          MenuItem(
            icon: AppIcons.question,
            title: 'legalInformation',
            showTrailing: true,
            action: ScreenPushAction(route: Routes.legalInformationScreen),
          ),
        ],
      ),
      if (isAuthenticated)
        MenuSection(
          items: [
            MenuItem(
              icon: AppIcons.signOut,
              title: 'logout',
              action: CustomAction(
                onTap: () async {
                  final shouldLogout =
                      await LogoutDialog.show(context) ?? false;
                  if (shouldLogout) {
                    context.read<LogoutCubit>().logout();
                  }
                },
              ),
            ),
          ],
        ),
    ];

    return ProfileListenersScope(
      child: AppScaffold(
        appBar: AppBar(
          title: Text('myProfile'.translate(context)),
          automaticallyImplyLeading: false,
          actions: [
            if (isAuthenticated)
              IconButton(
                onPressed: () {
                  ShareUtility.share(
                    context,
                    SellerDeepLink(AppSession.currentUser!.id),
                  );
                },
                icon: Icon(AppIcons.shareNetwork),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            if (!isAuthenticated) return;
            context.read<VerificationRequestCubit>().fetchVerificationRequest();
            context.read<UserProfileCubit>().getUserProfile();
            context.read<FollowingListCubit>().getUsers();
            context.read<FollowersListCubit>().getUsers();
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: context.bodyPadding().copyWith(
              bottom: CustomBottomNavigationBar.height(context),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 20,
              children: [
                ProfileHeader(),
                if (isAuthenticated) UserVerificationCard(),
                MyActivitySection(),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: menuSections.length,
                  separatorBuilder: (_, _) => 16.vGap,
                  itemBuilder: (context, index) =>
                      MenuSectionWidget(section: menuSections[index]),
                ),
                if (isAuthenticated)
                  AppButton(
                    variant: AppButtonVariant.text,
                    width: AppButtonWidth.content,
                    foregroundColor: Colors.red,
                    size: AppButtonSize.compact,
                    onPressed: () async {
                      if (Constant.systemSettings.demoMode) {
                        HelperUtils.showSnackBarMessage(
                          context,
                          'demoWarning'.translate(context),
                        );
                      } else {
                        final shouldDelete =
                            await DeleteAccountDialog.show(context) ?? false;
                        if (shouldDelete) {
                          context
                              .read<DeleteAccountCubit>()
                              .deleteUserAccount();
                        }
                      }
                    },
                    icon: Icon(AppIcons.trash),
                    title: 'deleteAccount',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> shareApp(BuildContext context) async {
    final appUrl = Constant.systemSettings.storeLink;
    final sharePosition = Rect.fromLTWH(
      0,
      0,
      context.screenWidth,
      context.screenHeight / 2,
    );
    await SharePlus.instance.share(
      ShareParams(
        text:
            '${AppConfig.applicationName}\n$appUrl\n${"shareApp".translate(context)}',
        sharePositionOrigin: sharePosition,
      ),
    );
  }

  Future<void> rateUs() {
    final appStoreId = Constant.systemSettings.storeLink?.split('/').lastOrNull;
    return InAppReview.instance.openStoreListing(appStoreId: appStoreId);
  }
}
