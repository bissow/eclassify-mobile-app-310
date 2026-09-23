import 'package:eClassify/app/screens/app_update_screen.dart';
import 'package:eClassify/app/screens/main_screen.dart';
import 'package:eClassify/app/screens/maintenance_mode.dart';
import 'package:eClassify/app/screens/splash_screen.dart';
import 'package:eClassify/core/screens/pdf_viewer.dart';
import 'package:eClassify/features/ad_posting/screens/ad_posting_screen.dart';
import 'package:eClassify/features/ad_posting/screens/ad_posting_success_screen.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/media_selection/video_ad_editor.dart';
import 'package:eClassify/features/advertisement/screens/details/ad_details_screen.dart';
import 'package:eClassify/features/advertisement/screens/select_buyer/select_buyer_screen.dart';
import 'package:eClassify/features/auth/ui/screens/auth_screen.dart';
import 'package:eClassify/features/auth/ui/screens/email_verification_screen.dart';
import 'package:eClassify/features/auth/ui/screens/otp_verification_screen.dart';
import 'package:eClassify/features/auth/ui/screens/set_new_password_screen.dart';
import 'package:eClassify/features/blogs/screens/blog_details_screen.dart';
import 'package:eClassify/features/blogs/screens/blogs_screen.dart';
import 'package:eClassify/features/category/screens/category_browsing_screen.dart';
import 'package:eClassify/features/chat/screens/chat_screen.dart';
import 'package:eClassify/features/chat/screens/inbox/blocked_user_list_screen.dart';
import 'package:eClassify/features/chat/screens/inbox/seller_item_chat_screen.dart';
import 'package:eClassify/features/company_details/screens/company_page_screen.dart';
import 'package:eClassify/features/company_details/screens/contact_us.dart';
import 'package:eClassify/features/faqs/screens/faqs_screen.dart';
import 'package:eClassify/features/favorite/screens/favorite_screen.dart';
import 'package:eClassify/features/followers/screens/follow_users_screen.dart';
import 'package:eClassify/features/home/screens/change_language_screen.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_filter/category_filter_screen.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_filter/filter_screen.dart';
import 'package:eClassify/features/item/screens/item_list_screen/item_list_screen.dart';
import 'package:eClassify/features/item/screens/my_items/my_items_tab_screen.dart';
import 'package:eClassify/features/jobs/screens/job_application_form.dart';
import 'package:eClassify/features/jobs/screens/job_application_list_screen.dart';
import 'package:eClassify/features/location/screens/location_screen.dart';
import 'package:eClassify/features/location/screens/widgets/location_map_picker.dart';
import 'package:eClassify/features/notification/screens/notification_details_screen.dart';
import 'package:eClassify/features/notification/screens/notification_list_screen.dart';
import 'package:eClassify/features/onboarding/screens/onboarding_screen.dart';
import 'package:eClassify/features/profile/screens/help_and_support_screen.dart';
import 'package:eClassify/features/profile/screens/legal_information_screen.dart';
import 'package:eClassify/features/reels/screens/video_ads_screen.dart';
import 'package:eClassify/features/review/screens/review_screen.dart';
import 'package:eClassify/features/seller/screens/seller_profile_screen.dart';
import 'package:eClassify/features/subscription/screens/active_plan_screen.dart';
import 'package:eClassify/features/subscription/screens/subscription_package_screen.dart';
import 'package:eClassify/features/subscription/screens/subscription_screen.dart';
import 'package:eClassify/features/subscription/screens/transaction/transaction_history_screen.dart';
import 'package:eClassify/features/subscription/screens/transaction/transaction_receipt_screen.dart';
import 'package:eClassify/features/subscription/screens/widgets/subscription_category_selection.dart';
import 'package:eClassify/features/user_profile/screens/user_profile_screen.dart';
import 'package:eClassify/features/verification/screens/verification_completed_screen.dart';
import 'package:eClassify/features/verification/screens/verification_introduction.dart';
import 'package:eClassify/features/verification/screens/verification_screen.dart';
import 'package:eClassify/features/store/screens/nearby_stores_screen.dart';
import 'package:eClassify/features/store/screens/store_details_screen.dart';
import 'package:eClassify/features/store/screens/store_setup_screen.dart';
import 'package:eClassify/features/offers/screens/offers_screen.dart';
import 'package:eClassify/features/offers/screens/seller_promotions_screen.dart';
import 'package:flutter/material.dart';

/// Class containing all route names and navigation logic
class Routes {
  /// Authentication Routes
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String auth = 'auth';
  static const String emailVerification = 'emailVerification';
  static const String otpVerification = 'otpVerification';
  static const String forgotPassword = 'forgotPassword';
  static const String phonePasswordResetOtp = 'phonePasswordResetOtp';
  static const String setNewPassword = 'setNewPassword';
  static const String userProfile = 'userProfile';

  /// Main Navigation Routes
  static const String main = 'main';
  static const String itemsList = 'itemsList';
  static const String addItem = 'addItem';
  static const String appUpdate = '/appUpdate';

  /// Settings & Profile Routes
  static const String contactUs = '/contactUs';
  static const String companyPage = '/companyPage';
  static const String notificationListScreen = 'notificationpage';
  static const String notificationDetailsScreen = 'notificationdetailpage';
  static const String helpAndSupportScreen = '/helpAndSupport';
  static const String legalInformationScreen = '/legalInformation';

  /// Feature Routes
  static const String filterScreen = 'filterScreen';
  static const String blogsScreen = '/blogsScreen';
  static const String blogDetailsScreen = '/blogDetailsScreen';
  static const String maintenanceMode = '/maintenanceMode';
  static const String favoritesScreen = '/favoriteScreen';
  static const String reviewScreen = '/reviewScreen';

  /// Location & Category Routes
  static const String languageListScreen = '/languageListScreen';
  static const String subCategoryScreen = '/subCategoryScreen';
  static const String categoryFilterScreen = '/categoryFilterScreen';
  static const String postedSinceFilterScreen = '/postedSinceFilterScreen';
  static const String categoryBrowsing = '/categoryBrowsing';

  /// Item Management Routes
  static const String myAdvertisment = '/myAdvertisment';
  static const String transactionHistory = '/transactionHistory';
  static const String myItemScreen = '/myItemScreen';
  static const String pdfViewerScreen = '/pdfViewerScreen';
  static const String adDetailsScreen = '/adDetailsScreen';

  /// Location Management Routes
  static const String locationScreen = '/locationScreen';
  static const String locationMapPicker = '/locationMapPicker';

  /// Seller Routes
  static const String sellerProfileScreen = '/sellerProfileScreen';
  static const String verificationIntroduction =
      '/sellerIntroVerificationScreen';
  static const String verification = '/sellerVerificationScreen';
  static const String verificationComplete =
      '/sellerVerificationCompleteScreen';

  /// Item Creation Routes
  static const String adPostingScreen = '/adPostingScreen';
  static const String adPostingSuccessScreen = '/adPostingSuccessScreen';
  static const String videoAdEditor = '/videoAdEditor';
  static const String videoAdsScreen = '/videoAdsScreen';

  /// Other Routes
  static const String faqsScreen = '/faqsScreen';
  static const String selectBuyer = '/selectBuyer';
  static const String blockedUserListScreen = '/blockedUserListScreen';
  static const String jobApplicationForm = '/jobApplicationForm';
  static const String jobApplicationList = '/jobApplicationList';

  static const String followersScreen = '/followersScreen';

  static const String subscriptionScreen = '/subscriptionScreen';
  static const String subscriptionCategorySelectionScreen =
      '/subscriptionCategorySelectionScreen';
  static const String subscriptionPackageScreen = '/subscriptionPackageScreen';
  static const String activePlanScreen = '/activePlanScreen';

  static const String sellerItemChatScreen = '/sellerItemChatScreen';
  static const String chatScreen = '/chatScreen';

  static const String transactionReceipt = '/transactionReceipt';

  /// Store & Shop Discovery Routes
  static const String nearbyStores = '/nearbyStores';
  static const String storeDetails = '/storeDetails';
  static const String storeSetup = '/storeSetup';

  /// Offers & Promotions Routes
  static const String offers = '/offers';
  static const String sellerPromotions = '/sellerPromotions';

  /// Generates routes based on the provided settings
  static Route onGenerateRouted(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return SplashScreen.route(routeSettings);
      case offers:
        return OffersScreen.route(routeSettings);
      case sellerPromotions:
        return SellerPromotionsScreen.route(routeSettings);
      case nearbyStores:

        return NearbyStoresScreen.route(routeSettings);
      case storeDetails:
        return StoreDetailsScreen.route(routeSettings);
      case storeSetup:
        return StoreSetupScreen.route(routeSettings);
      case onboarding:
        return OnboardingScreen.route(routeSettings);
      case main:
        return MainScreen.route(routeSettings);
      case auth:
        return AuthScreen.route(routeSettings);
      case emailVerification:
        return EmailVerificationScreen.route(routeSettings);
      case otpVerification:
        return OtpVerificationScreen.route(routeSettings);
      case phonePasswordResetOtp:
        return OtpVerificationScreen.route(routeSettings);
      case setNewPassword:
        return SetNewPasswordScreen.route(routeSettings);
      case userProfile:
        return UserProfileScreen.route(routeSettings);
      case categoryFilterScreen:
        return CategoryFilterScreen.route(routeSettings);
      case maintenanceMode:
        return MaintenanceMode.route(routeSettings);
      case languageListScreen:
        return LanguagesListScreen.route(routeSettings);
      case contactUs:
        return ContactUs.route(routeSettings);
      case companyPage:
        return CompanyPageScreen.route(routeSettings);
      case filterScreen:
        return FilterScreen.route(routeSettings);
      case blogsScreen:
        return BlogsScreen.route(routeSettings);
      case blogDetailsScreen:
        return BlogDetailsScreen.route(routeSettings);
      case notificationListScreen:
        return NotificationListScreen.route(routeSettings);
      case notificationDetailsScreen:
        return NotificationDetailsScreen.route(routeSettings);
      case jobApplicationForm:
        return JobApplicationForm.route(routeSettings);
      case jobApplicationList:
        return JobApplicationListScreen.route(routeSettings);
      case favoritesScreen:
        return FavoriteScreen.route(routeSettings);
      case transactionHistory:
        return TransactionHistory.route(routeSettings);
      case myItemScreen:
        return MyItemsScreen.route(routeSettings);
      case blockedUserListScreen:
        return BlockedUserListScreen.route(routeSettings);
      case locationScreen:
        return LocationScreen.route(routeSettings);
      case locationMapPicker:
        return LocationMapPicker.route(routeSettings);
      case itemsList:
        return ItemListScreen.route(routeSettings);
      case faqsScreen:
        return FaqsScreen.route(routeSettings);
      case adPostingScreen:
        return AdPostingScreen.route(routeSettings);
      case adPostingSuccessScreen:
        return AdPostingSuccessScreen.route(routeSettings);
      case videoAdEditor:
        return VideoAdEditor.route(routeSettings);
      case videoAdsScreen:
        return VideoAdsScreen.route(routeSettings);
      case adDetailsScreen:
        return AdDetailsScreen.route(routeSettings);
      case pdfViewerScreen:
        return PdfViewer.route(routeSettings);
      case selectBuyer:
        return SelectBuyerScreen.route(routeSettings);
      case sellerProfileScreen:
        return SellerProfileScreen.route(routeSettings);
      case verificationIntroduction:
        return VerificationIntroductionScreen.route(routeSettings);
      case verification:
        return VerificationScreen.route(routeSettings);
      case verificationComplete:
        return VerificationCompletedScreen.route(routeSettings);
      case reviewScreen:
        return ReviewScreen.route(routeSettings);
      case followersScreen:
        return FollowUsersScreen.route(routeSettings);
      case subscriptionScreen:
        return SubscriptionScreen.route(routeSettings);
      case subscriptionCategorySelectionScreen:
        return SubscriptionCategorySelection.route(routeSettings);
      case subscriptionPackageScreen:
        return SubscriptionPackageScreen.route(routeSettings);
      case activePlanScreen:
        return ActivePlanScreen.route(routeSettings);
      case sellerItemChatScreen:
        return SellerItemChatScreen.route(routeSettings);
      case chatScreen:
        return ChatScreen.route(routeSettings);
      case categoryBrowsing:
        return CategoryBrowsingScreen.route(routeSettings);
      case transactionReceipt:
        return TransactionReceiptScreen.route(routeSettings);
      case helpAndSupportScreen:
        return HelpAndSupportScreen.route(routeSettings);
      case legalInformationScreen:
        return LegalInformationScreen.route(routeSettings);
      case appUpdate:
        return AppUpdateScreen.route(routeSettings);
      default:
        return _defaultRoute();
    }
  }

  /// Returns the default route
  static Route _defaultRoute() {
    return MaterialPageRoute(builder: (context) => const Scaffold());
  }
}
