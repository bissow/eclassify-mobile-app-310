# Mobile App Changelog: Sales & Offer Zone with Promotions, Campaigns & Promote Ad Module

**Date:** 2026-09-09  
**Project:** Eclassify Flutter Mobile App  
**Version:** 3.2.0  
**Compatibility:** 100% Backward-compatible with existing Listing, Ad Posting, User Profile, and Details screens. Supports Android & iOS with dynamic Light & Dark themes.

---

## 1. Overview of Changes

This release delivers the complete **Sales & Offer Zone Hub** for the mobile application, featuring active marketing **Campaigns**, tabbed **Promotions** (Flash Sales, Daily Deals, Stock Clearance), **Spotlight Deals** horizontal carousel, and seller monetization actions (**Promote Ad** and **Join Sale**).

---

## 2. Modified & Created Files

### 2.1 Networking & Endpoints
- **[MODIFY] lib/core/network/api_endpoints.dart**
  - Added endpoints:
    - getOfferCampaigns: offers/campaigns
    - getOfferCampaignDetail: offers/campaigns/{slug}
    - getActivePromotions: offers/promotions
    - getFlashSales: offers/flash-sales
    - getClearanceSales: offers/clearance-sales
    - getDealsOfTheDay: offers/deals-of-the-day
    - getSpotlightAds: offers/spotlight
    - getPromotionItems: offers/promotions/{slug}/items
    - sellerPromotionsAvailable: seller/promotions/available
    - sellerPromotionOptions: seller/items/{id}/promotions/options
    - sellerItemPromote: seller/items/{id}/promote
    - sellerItemJoinPromotion: seller/items/{id}/promotions/join

### 2.2 Design System & Assets
- **[MODIFY] lib/core/constants/app_icons.dart**
  - Added new icons: percent, lightning, lightningFill, 	ag, 	agFill, ire, ireFill.

### 2.3 Data Models
- **[NEW] lib/features/offers/models/campaign_model.dart**
  - Model for seasonal and holiday marketing campaigns (	itle, slug, annerImage, startDate, endDate, highlightBadge).
- **[NEW] lib/features/offers/models/promotion_model.dart**
  - Model for child promotions (promotionType, discount, discountType, isCountdownEnabled).
- **[NEW] lib/features/offers/models/promotion_item_model.dart**
  - Model for promotional products supporting both flat and nested ad payloads, calculated discounts, countdown timers, and remaining/total stock trackers.
- **[NEW] lib/features/offers/models/ad_promotion_options_model.dart**
  - Model for seller package allowances and quotas for Daily Bump Up, Top Ad, and Spotlight.

### 2.4 Repositories & State Management (BLoC / Cubit)
- **[NEW] lib/features/offers/repository/offers_repository.dart**
  - Communicates with all public offer APIs and authenticated seller promotion endpoints with location and pagination filters.
  - Implements `_extractList` helper to safely parse paginated Laravel response structures (`response['data']['data']`), collections, and nested payloads (`response['data']['promotions']`).
- **[NEW] lib/features/offers/cubits/offers_cubit.dart**
  - State management for the Offer Zone: loads campaigns, spotlights, and tabbed items concurrently, with support for location-based refetching and tab switching.
- **[NEW] lib/features/offers/cubits/seller_ad_promote_cubit.dart**
  - Handles seller promotion boosting (Daily Bump, Top Ad, Spotlight) and joining active promotional campaigns.

### 2.5 UI Screens & Widgets
- **[NEW] lib/features/offers/screens/offers_screen.dart**
  - Central Offer Zone screen with:
    - Tab bar for quick filtering (All Offers, Flash Sales, Daily Deals, Clearance).
    - Gradient Hero Banner for top active campaign.
    - Horizontal Spotlight carousel with gold sparkle indicator.
    - 2-column responsive grid of promotional items.
    - Pull-to-refresh integration.
- **[NEW] lib/features/offers/screens/widgets/offer_item_card.dart**
  - Promotional item card featuring live ticking countdown timer badge, discount percentage pill, strikethrough price, and linear stock progress bar.
- **[NEW] lib/features/offers/screens/widgets/promote_ad_bottom_sheet.dart**
  - Interactive bottom sheet allowing sellers to boost listings using their subscription package quotas.
- **[NEW] lib/features/offers/screens/widgets/add_to_promotion_bottom_sheet.dart**
  - Bottom sheet allowing sellers to enroll their items into active Flash Sales or Clearance events with custom discounts and stock limits.

### 2.6 Route & Screen Integrations
- **[MODIFY] lib/app/routes.dart**
  - Registered Routes.offers = '/offers' and route generator routing to OffersScreen.
- **[MODIFY] lib/features/profile/screens/profile_tab_screen.dart**
  - Added "Offer Zone & Promotions" navigation entry to profile menu with amber fire icon.
- **[MODIFY] lib/features/advertisement/screens/details/widgets/feature_ad_card.dart**
  - Added "Promote Ad" and "Join Sale" action buttons directly on the seller's active ad detail card.
- **[MODIFY] ssets/languages/language.json**
  - Added localization strings for all offer zone sections, deals, badges, and seller promotion sheets.

---

## 3. Verification & Quality Assurance

- **Static Analysis:** Verified using `flutter analyze` with 0 errors and 0 warnings in any offer zone or modified feature files.
- **Theme Support:** Fully compatible with Light and Dark modes (`context.colorScheme.surface`, `context.colorScheme.primary`, `context.colorScheme.outlineVariant`).

---

## 4. Seller Verification & Subscription Package Guidance

- **[MODIFY] lib/features/advertisement/screens/details/widgets/feature_ad_card.dart**:
  - Validates `AppSession.currentUser?.isVerified` before showing `PromoteAdBottomSheet` or `AddToPromotionBottomSheet`.
  - Prompts unverified users with `AppDialog` providing clear information and direct navigation to `Routes.verification`.
- **[MODIFY] lib/features/offers/models/ad_promotion_options_model.dart**:
  - Parses `requiresVerification`, `requiresPackage`, `hasActivePackage`, `hasQuota`, and `message`.
- **[MODIFY] lib/features/offers/screens/widgets/promote_ad_bottom_sheet.dart**:
  - Displays verification and package requirement notice banners with direct navigation buttons to `Routes.verification` and `Routes.subscriptionPackageScreen`.
  - Disables the `boostNow` button when required credentials or package quotas are absent.
- **[MODIFY] lib/features/offers/screens/widgets/add_to_promotion_bottom_sheet.dart**:
  - Displays verification and package requirement cards with direct navigation to `Routes.verification` and `Routes.subscriptionPackageScreen`.
  - Disables the submission button when criteria are unmet.
- **[MODIFY] assets/languages/language.json**:
  - Added localization keys for verification required titles, descriptions, and package subscription prompts.

---

## 5. Promotional & Marketing Perks on Subscription Packages

- **[MODIFY] lib/features/subscription/models/subscription_package.dart**:
  - Updated `SubscriptionPackageType` enum to support `'promotional'` packages.
  - Added model fields: `allowsPromotions`, `promotionItemLimit`, `allowsDailyBumpUp`, `dailyBumpUpLimit`, `allowsTopAd`, `topAdLimit`, `allowsSpotlight`, and `spotlightLimit`.
- **[MODIFY] lib/features/subscription/screens/widgets/package_widget.dart**:
  - Added `_buildPromotionalFeatures()` to display bundled promotional perks with badge pills and quota numbers (`(5 items)` / `(3 times)` / `(unlimited)`).
- **[MODIFY] assets/languages/language.json**:
  - Added localization keys: `promotionsMarketingPerks`, `salesCampaignPromotionsIncluded`, `dailyBumpUpIncluded`, `topAdBoostIncluded`, `spotlightCarouselIncluded`, `items`, and `times`.

---

## 6. Multi-Campaign Carousel, Campaign Ends In Countdown & Ad Details Link Fix

- **[MODIFY] lib/features/offers/models/promotion_item_model.dart**:
  - Resolved ad details navigation payload: supports `json['item']` in addition to `json['ad']` and root `json` so that `itemSlug` and `itemId` are consistently populated and not empty.
- **[MODIFY] lib/features/offers/screens/offers_screen.dart**:
  - Replaced single campaign banner with `_CampaignHeroSlider`: implemented a smooth auto-scrolling `PageView` when more than one active campaign exists, complete with active indicator dots.
  - Added a live ticking `_CampaignHeroCard` featuring a prominent "CAMPAIGN ENDS IN" countdown box with days, hours, minutes, and seconds tiles.
- **[MODIFY] assets/languages/language.json**:
  - Added translations for `campaignEndsIn`, `days`, `hours`, `minutes`, and `seconds`.

---

## 7. Exhaustive Switch Pattern Matching for Promotional Packages

- **[MODIFY] lib/features/subscription/screens/active_plan_screen.dart**:
  - Added `SubscriptionPackageType.promotional` case to `switch (packages[index].type)` returning `'promotionalPackage'.translate(context)`.
- **[MODIFY] lib/features/subscription/screens/widgets/no_package_available_dialog.dart**:
  - Added `(SubscriptionPackageType.promotional, _)` exhaustive pattern matches to both `contentText` and `routeConfig` switch expressions.
- **[MODIFY] assets/languages/language.json**:
  - Added `"promotionalPackage": "Promotional Package"` localization string.

---

## 8. Real-Time Active Promotion Badges, Seller Analytics & History Screen

- **[NEW] lib/features/item/models/active_promotions_summary.dart**:
  - Structured model encapsulating active promotional status, Top Ad, Spotlight, sales array with campaign info and discounts, and boost details.
- **[MODIFY] lib/features/item/models/item_preview.dart & item.dart**:
  - Added `activePromotions` (`ActivePromotionsSummary?`) parsed automatically from API responses.
- **[NEW] lib/features/item/screens/widgets/promotion_badge_strip.dart**:
  - Reusable, theme-aware badge strip widget rendering `Top Ad` (amber flame), `Spotlight` (purple sparkle), and active sales/campaign pills with markdown discount percentage badges.
- **[MODIFY] lib/features/item/screens/widgets/item_card.dart**:
  - Integrated `PromotionBadgeStrip` into `_ItemListTile` below the status header for seller listings with active promotions.
- **[NEW] lib/features/offers/models/seller_promotions_analytics_model.dart**:
  - Models for seller promotion analytics summary KPIs, breakdown maps, and paginated history items with active duration, claimed units, and estimated revenue.
- **[MODIFY] lib/features/offers/repository/offers_repository.dart**:
  - Added `getPromotionsAnalytics()` and `getPromotionsHistory({ filterType, campaignId, status, page, limit })`.
- **[NEW] lib/features/offers/cubits/seller_promotions_analytics_cubit.dart**:
  - BLoC/Cubit managing dashboard metrics, tabbed filter state, pagination, and refresh operations.
- **[NEW] lib/features/offers/screens/seller_promotions_screen.dart**:
  - Comprehensive Flutter analytics dashboard with KPI cards (Active Promotions, Units Sold/Claimed, Revenue, Buyer Savings), breakdown by type, horizontal filter chips, and detailed history list.
- **[MODIFY] lib/app/routes.dart**:
  - Registered route `Routes.sellerPromotions` (`/sellerPromotions`) with route builder `SellerPromotionsScreen.route`.
- **[MODIFY] lib/features/profile/screens/profile_tab_screen.dart**:
  - Added "Promotions & Sales" navigation item under user profile.
- **[MODIFY] lib/features/item/screens/my_items/my_items_tab_screen.dart**:
  - Added quick-access analytics icon button in the AppBar.
- **[MODIFY] assets/languages/language.json**:
  - Added localization keys for analytics metrics, history filtering, and badges.

---

## 9. Daily Bump Up Badge & Boosts History Integration

- **[MODIFY] lib/features/item/models/active_promotions_summary.dart**:
  - Added `isDailyBumped` boolean attribute parsed from `json['is_daily_bumped']`.
- **[MODIFY] lib/features/item/screens/widgets/promotion_badge_strip.dart**:
  - Added `_BadgeChip` for Daily Bump Up with `AppIcons.arrowsClockwise` icon and `'dailyBump'.translate(context)` in cyan styling.
- **[MODIFY] lib/features/offers/models/seller_promotions_analytics_model.dart**:
  - Added `views` and `lastBumpedAt` fields to `SellerPromotionHistoryItem` with resilient fallback key mapping for unified boost and sales responses.
- **[MODIFY] lib/features/offers/screens/seller_promotions_screen.dart**:
  - Added `daily_bump_up`, `top_ad`, and `spotlight` filter chips.
  - Enhanced `_HistoryCard` to display views count, last bumped timestamp, and boost-specific icon pills.
- **[MODIFY] assets/languages/language.json**:
  - Added translation keys: `dailyBump`, `lastBumped`, and `views`.

---

## 10. Verified Seller Analytics Access Gate

- **[MODIFY] lib/features/offers/screens/seller_promotions_screen.dart**:
  - Added `_buildVerificationRequiredView()` to gate promotions and analytics for unverified sellers.
  - Displays feature benefits card with direct navigation button to `Routes.verification`.

---

## 11. Verification Lifecycle State Management & Locked Verification Screens

- **[MODIFY] lib/features/verification/screens/verification_screen.dart**:
  - **Under Review Screen (`_buildUnderReviewView`)**: When verification status is `pending` or `resubmitted`, hides form inputs, custom fields, and submit button. Renders an amber status badge, review explanation notice that submissions are undergoing audit and cannot be modified, and "Back to Profile" CTA.
  - **Already Verified Screen (`_buildVerifiedView`)**: When user is already verified (`AppSession.currentUser?.isVerified == true` or status is `approved`), hides form fields and renders a shield seal checkmark, "Account Verified" headline, locked credentials notice, and "Back to Profile" CTA.
  - Form inputs are exclusively enabled for new submissions or rejected requests (with alert displaying the admin rejection reason).
- **[MODIFY] lib/features/verification/screens/verification_introduction.dart**:
  - Checks `AppSession.currentUser?.isVerified`. Automatically redirects verified users to the locked verification view.
- **[MODIFY] lib/features/profile/screens/widgets/user_verification_card.dart**:
  - Added "Check Verification Status" action button for pending requests navigating directly to the under review status screen.
- **[MODIFY] lib/features/offers/screens/seller_promotions_screen.dart**:
  - Uses `VerificationRequestCubit` to distinguish between unverified and under-review states. Displays "Verification Request Under Review" badge and "Check Verification Status" button when pending.
- **[MODIFY] lib/features/offers/screens/widgets/promote_ad_bottom_sheet.dart & add_to_promotion_bottom_sheet.dart**:
  - Checks `verificationStatus` from promotion options/eligibility. Shows "Verification in review" notice and "Check Verification Status" CTA button when user is pending approval.
- **[MODIFY] assets/languages/language.json**:
  - Added translation keys: `verificationUnderReviewTitle`, `verificationUnderReviewNotice`, `verificationUnderReviewMsg`, `checkVerificationStatus`, `accountVerifiedLockedNotice`, `verificationLockedNotice`.
