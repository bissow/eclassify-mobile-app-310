class ApiEndpoints {
  // ==================== Auth & User ====================
  static const String login = "user-signup";
  static const String logout = "logout";
  static const String userExists = "user-exists";
  static const String resetPassword = "reset-password";
  static const String updateProfile = "update-profile";
  static const String userProfile = 'get-user-info';
  static const String deleteUser = "delete-user";
  static const String getSeller = "get-seller";

  // ==================== OTP / Twilio ====================
  static const String getTwilioOtp = 'get-otp';
  static const String verifyTwilioOtp = 'verify-otp';

  // ==================== Home & Discovery ====================
  static const String getSlider = "get-slider";
  static const String getCategories = "get-categories";
  static const String getHomeConfiguration = 'get-home-screen';
  static const String getPopularCategories = 'get-popular-categories';
  static const String getFeaturedSection = "get-featured-section";
  static const String getBannerAds = 'get-banner-ads';
  static const String getCustomFields = "get-customfields";
  static const String getNotificationList = "get-notification-list";

  // ==================== Items / Listings ====================
  static const String getItem = "get-item-list";
  static const String getMyItem = "my-items";
  static const String updateItem = "update-item";
  static const String addItem = "add-item";
  static const String uploadMedia = "upload-media";
  static const String deleteItem = "delete-item";
  static const String updateItemStatus = "update-item-status";
  static const String makeItemFeatured = "make-item-featured";
  static const String renewItem = "renew-item";
  static const String getItemStatus = 'get-item-status';
  static const String getItemBuyerList = "item-buyer-list";
  static const String manageFavourite = "manage-favourite";
  static const String getFavoriteItem = "get-favourite-item";
  static const String myPurchasedItems = "my-purchased-items";

  // ==================== Packages & Payments ====================
  static const String getPackage = "get-package";
  static const String getActivePackages = "get-user-purchased-packages";
  static const String getPaymentSettings = "get-payment-settings";
  static const String getPaymentIntent = "payment-intent";
  static const String inAppPurchase = "in-app-purchase";
  static const String assignFreePackage = "assign-free-package";
  static const String getLimitsOfPackage = "get-limits";
  static const String paymentReceipt = 'get-payment-receipt';
  static const String bankTransferUpdate = "bank-transfer-update";
  static const String getPaymentDetails = "payment-transactions";
  static const String makePaymentTransactionFail =
      "make-payment-transaction-fail";

  // ==================== Location ====================
  static const String getCountries = "countries";
  static const String getStates = "states";
  static const String getCities = "cities";
  static const String getAreas = "areas";
  static const String getLocation = "get-location";

  // ==================== Reviews & Reports ====================
  static const String getReportReasons = "get-report-reasons";
  static const String addReports = "add-reports";
  static const String addItemReview = "add-item-review";
  static const String getMyReview = "my-review";
  static const String addReviewReport = "add-review-report";

  // ==================== Verification ====================
  static const String getVerificationField = "verification-fields";
  static const String sendVerificationRequest = "send-verification-request";
  static const String getVerificationRequest = "verification-request";

  // ==================== Jobs ====================
  static const String applyForJob = "job-apply";
  static const String getJobApplications = "get-job-applications";
  static const String myJobApplications = "my-job-applications";
  static const String updateJobApplicationsStatus =
      "update-job-applications-status";

  // ==================== Chat & Messaging ====================
  static const String sendMessage = "send-message";
  static const String getChatList = "chat-list";
  static const String chatMessages = "chat-messages";
  static const String deleteChat = "delete-chat";
  static const String deleteChatMessages = "delete-chat-messages";
  static const String blockUser = "block-user";
  static const String unBlockUser = "unblock-user";
  static const String blockedUsersList = "blocked-users";
  static const String chatTemplates = "chat-template-questions";

  // ==================== Offers ====================
  static const String itemOffer = "item-offer";
  static const String chatItemOffers = 'item-offer-list';

  // ==================== Enquiry ====================

  // ==================== Social / Follow ====================
  static const String followUser = 'follow-user';
  static const String unFollowUser = 'unfollow-user';
  static const String followers = 'followers';
  static const String following = 'following';

  // ==================== Advertisement ====================

  // ==================== AI ====================
  static const String generateMeta = 'gemini/generate-meta';
  static const String generateDescription = 'gemini/generate-description';

  // ==================== Blog ====================
  static const String getBlog = "blogs";
  static const String popularBlogs = 'get-popular-blogs';
  static const String blogCategories = 'get-blog-categories';
  static const String blogFeedback = 'set-blog-feedback';
  static const String blogTags = 'blog-tags';

  // ==================== Reels ====================
  static const String getReels = "get-reels";
  static const String getMyReels = "get-my-reels";
  static const String getLikedReels = "get-liked-reels";
  static const String manageReelLike = "manage-reel-like";

  // ==================== Stores & Nearby Sellers ====================
  static const String getStores = "get-stores";
  static const String getStoreDetail = "get-store-detail";
  static const String getStoreSlugs = "get-store-slugs";
  static const String setupStore = "setup-store";
  static const String getMyStore = "get-my-store";
  static const String toggleStoreStatus = "toggle-store-status";

  // ==================== Offers & Campaigns ====================
  static const String getOffersCampaigns = "offers/campaigns";
  static const String getOffersCampaignDetail = "offers/campaign-detail";
  static const String getOffersPromotions = "offers/promotions";
  static const String getOffersPromotionDetail = "offers/promotion-detail";
  static const String getOffersPromotionItems = "offers/promotion-items";
  static const String getOffersFlashSales = "offers/flash-sales";
  static const String getOffersClearanceSales = "offers/clearance-sales";
  static const String getOffersDealsOfTheDay = "offers/deals-of-the-day";
  static const String getOffersSpotlightAds = "offers/spotlight-ads";

  // ==================== Seller Promotions & Boosts ====================
  static const String getSellerAvailablePromotions = "seller/promotions/available";
  static const String getSellerMyPromotionItems = "seller/promotions/my-items";
  static const String addSellerPromotionItem = "seller/promotions/add-item";
  static const String updateSellerPromotionItem = "seller/promotions/update-item";
  static const String toggleSellerPromotionItemStatus = "seller/promotions/toggle-item-status";
  static const String deleteSellerPromotionItem = "seller/promotions/delete-item";
  static const String getSellerPromotionOptions = "seller/items/promotion-options";
  static const String promoteSellerAd = "seller/items/promote";
  static const String getSellerPromotionsAnalytics = "seller/promotions/analytics";
  static const String getSellerPromotionsHistory = "seller/promotions/history";

  // ==================== Misc ====================
  static const String getLanguage = "get-languages";
  static const String getSystemSettings = "get-system-settings";
  static const String getCurrencies = "get-currencies";
  static const String getTips = "tips";
  static const String getFaq = "faq";
  static const String contactUs = 'contact-us';
}
