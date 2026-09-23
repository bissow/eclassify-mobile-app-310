import 'package:eClassify/core/cubits/app_theme_cubit.dart';
import 'package:eClassify/core/cubits/app_update_cubit.dart';
import 'package:eClassify/core/cubits/bottom_nav_cubit.dart';
import 'package:eClassify/core/cubits/currencies_cubit.dart';
import 'package:eClassify/core/cubits/language_cubit.dart';
import 'package:eClassify/core/cubits/system_settings_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/fetch_item_cubit.dart';
import 'package:eClassify/features/chat/cubits/safety_tips_cubit.dart';
import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/features/auth/cubits/delete_account_cubit.dart';
import 'package:eClassify/features/auth/cubits/logout_cubit.dart';
import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/banner/cubits/banner_ad_cubit.dart';
import 'package:eClassify/features/category/cubits/category_validation_cubit.dart';
import 'package:eClassify/features/category/cubits/main_category_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_list_cubit.dart';
import 'package:eClassify/features/chat/cubits/seller_item_offers_cubit.dart';
import 'package:eClassify/features/favorite/cubits/item_favorite_cubit.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/features/home/cubits/featured_section_cubit.dart';
import 'package:eClassify/features/home/cubits/home_items_cubit.dart';
import 'package:eClassify/features/home/cubits/home_screen_configuration_cubit.dart';
import 'package:eClassify/features/home/cubits/popular_categories_cubit.dart';
import 'package:eClassify/features/home/cubits/slider_cubit.dart';
import 'package:eClassify/features/item/cubits/delete_item_cubit.dart';
import 'package:eClassify/features/location/cubits/leaf_location_cubit.dart';
import 'package:eClassify/features/location/cubits/location_cubit.dart';
import 'package:eClassify/features/notification/cubits/notification_event_cubit.dart';
import 'package:eClassify/features/reels/cubits/liked_reels_cubit.dart';
import 'package:eClassify/features/reels/cubits/reel_like_cubit.dart';
import 'package:eClassify/features/reels/cubits/video_ads_cubit.dart';
import 'package:eClassify/features/subscription/cubits/active_subscription_package_cubit.dart';
import 'package:eClassify/features/subscription/cubits/user_package_limit_cubit.dart';
import 'package:eClassify/features/user_profile/cubits/user_profile_cubit.dart';
import 'package:eClassify/features/verification/cubits/submit_verification_cubit.dart';
import 'package:eClassify/features/verification/cubits/verification_fields_cubit.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
import 'package:eClassify/features/store/cubits/my_store_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProviderRegistry {
  ProviderRegistry._internal();

  static final ProviderRegistry _instance = ProviderRegistry._internal();

  static ProviderRegistry get instance => _instance;

  final providers = [
    BlocProvider(create: (_) => SystemSettingsCubit()),
    BlocProvider(create: (_) => AppUpdateCubit()),
    BlocProvider(create: (_) => AppThemeCubit(), lazy: false),
    BlocProvider(create: (_) => AuthSessionCubit(), lazy: false),
    BlocProvider(create: (_) => LogoutCubit()),
    BlocProvider(create: (_) => DeleteAccountCubit()),
    BlocProvider(create: (_) => SliderCubit()),
    BlocProvider(create: (_) => LanguageCubit()),
    BlocProvider(create: (_) => CurrenciesCubit()),
    BlocProvider(create: (_) => FeaturedSectionCubit()),
    BlocProvider(create: (_) => HomeItemsCubit()),
    BlocProvider(create: (_) => DeleteItemCubit()),
    BlocProvider(create: (_) => UserPackageLimitCubit()),
    BlocProvider(create: (_) => SafetyTipsListCubit()),
    BlocProvider(create: (_) => VerificationFieldsCubit()),
    BlocProvider(create: (_) => SubmitVerificationCubit()),
    BlocProvider(create: (_) => VerificationRequestCubit()),
    BlocProvider(create: (_) => LocationCubit()),
    BlocProvider(create: (_) => LeafLocationCubit()),
    BlocProvider(create: (_) => UserProfileCubit()),
    BlocProvider(create: (_) => FetchItemCubit()),
    BlocProvider(create: (_) => ActiveSubscriptionPackageCubit()),
    BlocProvider(create: (_) => SellerItemOffersCubit()),
    BlocProvider(create: (_) => BuyingChatListCubit()),
    BlocProvider(create: (_) => FollowersListCubit()),
    BlocProvider(create: (_) => FollowingListCubit()),
    BlocProvider(create: (_) => MainCategoryCubit()),
    BlocProvider(create: (_) => CategoryValidationCubit()),
    BlocProvider(create: (_) => NotificationEventCubit()),
    BlocProvider(create: (_) => HomeConfigurationCubit()),
    BlocProvider(create: (_) => PopularCategoriesCubit()),
    BlocProvider(create: (_) => HomeBannerAdCubit()),
    BlocProvider(create: (_) => BottomNavCubit()),
    BlocProvider(create: (_) => VideoAdsCubit()),
    BlocProvider(create: (_) => ReelLikeCubit()),
    BlocProvider(create: (_) => LikedReelsCubit()),
    BlocProvider(create: (_) => ItemFavoriteCubit()),
    BlocProvider(create: (_) => MyStoreCubit()),
  ];

  /// Every cubit here holds data scoped to the current logged-in user.
  /// Called from `MainActivity`'s session-end listener whenever
  /// `AuthSessionCubit` emits `Unauthenticated` (logout, account deletion,
  /// or a 401) — kept here, next to `providers`, so adding a new
  /// user-scoped cubit above without also listing it here is a one-file
  /// oversight, not a two-file one.
  static final List<SessionScoped Function(BuildContext)> sessionScopedCubits =
      [
        (c) => c.read<LeafLocationCubit>(),
        (c) => c.read<BuyingChatListCubit>(),
        (c) => c.read<SellerItemOffersCubit>(),
        (c) => c.read<ItemFavoriteCubit>(),
        (c) => c.read<FollowersListCubit>(),
        (c) => c.read<FollowingListCubit>(),
        (c) => c.read<ActiveSubscriptionPackageCubit>(),
        (c) => c.read<UserPackageLimitCubit>(),
        (c) => c.read<VerificationRequestCubit>(),
        (c) => c.read<UserProfileCubit>(),
        (c) => c.read<LikedReelsCubit>(),
        (c) => c.read<MyStoreCubit>(),
      ];
}
