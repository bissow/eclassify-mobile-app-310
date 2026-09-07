# Store / Shop & Geolocation Nearby Available Sellers Module Changelog

**Project**: `eclassify-mobile-app` (Flutter)  
**Date**: September 08, 2026  
**Status**: Production Ready & Fully Verified

---

## 1. Overview
Implemented the **Store / Shop & Nearby Available Sellers / Stores Discovery** module in the Flutter application. This enables users to discover local merchants based on proximity, view store catalog & operating hours, and allow verified sellers to create and manage their dedicated digital storefront directly from their profile without disrupting core classified ad posting and browsing capabilities.

---

## 2. Changes Summary

### A. Core Network & Endpoints
- **`lib/core/network/api_endpoints.dart`**:
  - Added endpoints: `getStores`, `getStoreDetail`, `getStoreSlugs`, `setupStore`, `getMyStore`, `toggleStoreStatus`.
- **`lib/core/constants/app_icons.dart`**:
  - Added `storefront` and `storefrontFill` Phosphor icon mappings.

### B. Models Layer (`lib/features/store/models/`)
- **`store_model.dart`**:
  - `StoreModel`: comprehensive store entity with ID, name, slug, description, logo, banner, contact, email, address, latitude, longitude, city, state, country, areaName, website, taxNumber, openingTime, closingTime, workingDays, isVerified, status.
  - `StoreDistanceModel`: meters, kilometers, formatted distance string (`850 m`, `2.4 km`).
  - `StoreStatsModel`: activeItemsCount, totalItemsCount, averageRating, totalReviews, followersCount.
  - `StoreOwnerModel`: owner id, name, profile image, countryCode, isVerified.
- **`lib/features/auth/models/user.dart`**:
  - Added `hasStore` field mapping.

### C. Repository Layer (`lib/features/store/repository/`)
- **`store_repository.dart`**:
  - `getStores(...)`: Fetches paginated nearby stores with location filters (lat/lng, radius, city/state/country) and keyword search.
  - `getStoreDetail(...)`: Fetches complete store details, operating hours, ratings, and active store item catalog.
  - `getMyStore()`: Fetches current authenticated user's store profile.
  - `setupStore(...)`: Handles multipart/form-data creation and update of stores including logo and banner image uploads.
  - `toggleStoreStatus()`: Activates / deactivates store availability.

### D. State Management & Cubits (`lib/features/store/cubits/`)
- **`nearby_stores_cubit.dart`**: Paginated cubit handling nearby stores list, keyword debounced search, radius filtering (5 km - 100 km), and infinite scroll.
- **`store_details_cubit.dart`**: Loads store profile and items catalog with distance calculation.
- **`my_store_cubit.dart`**: Manages current user's store, status toggle, and implements `SessionScoped` for automated cache cleanup upon logout.
- **`store_setup_cubit.dart`**: Manages store creation/edit submission with loading/error handling.
- **`lib/app/register_cubits.dart`**: Registered `MyStoreCubit` in app-wide providers and session scoped cleanup.

### E. UI & Screens (`lib/features/store/screens/`)
- **`widgets/store_card.dart`**:
  - High-finish store card displaying cover banner, floating circular logo, verified seal badge, distance tag (`850 m`, `2.4 km`), star rating, address, and active items count badge.
  - Fully supports responsive Light and Dark themes.
- **`nearby_stores_screen.dart`**:
  - Location header connected with `LeafLocationCubit` and `Routes.locationScreen`.
  - Radius selector chips (`5 km`, `10 km`, `25 km`, `50 km`, `100 km`).
  - Real-time search bar with debounce.
  - Shimmer loading, error state with retry, and empty state with location picker CTA.
- **`store_details_screen.dart`**:
  - Collapsible SliverAppBar with cover banner, back button, and share action.
  - Profile header with store logo, verified badge, rating, formatted distance badge, and full address.
  - One-tap action buttons for Call, Email, and Website.
  - Tabbed interface:
    1. **Products Catalog**: Grid of items listed by the store using `ItemCard.grid`.
    2. **About & Hours**: Detailed description, operating hours (24/7 or custom time range), working days, tax ID, and address info.
- **`store_setup_screen.dart`**:
  - Complete store onboarding & edit form with cover banner picker, logo picker, name, description, address, central location picker, contact info, operating hours, and working days chips.
- **`lib/features/profile/screens/profile_tab_screen.dart`**:
  - Added Store / Shop section with "Nearby Stores & Shops" and "My Store / Shop" navigation items.
- **`lib/features/home/screens/widgets/home_search.dart`**:
  - Added 1-tap storefront discovery button inside the home search row.
- **`lib/app/routes.dart`**:
  - Registered `Routes.nearbyStores`, `Routes.storeDetails`, and `Routes.storeSetup`.

---

## 3. Verification & Quality Assurance
- Follows centralized `LeafLocation` and `LocationScreen` location management.
- Complete Light/Dark mode compatibility using `context.colorScheme`.
- Zero breaking changes to existing classified ads, chat, or user profiles.


# Mobile App Changelog: Store & Nearby Sellers Discovery Module

**Date:** 2026-09-08  
**Project:** Eclassify Classified Mobile App (Flutter)  
**Version:** 3.1.0  
**Compatibility:** Fully compatible with Android and iOS, supporting Light & Dark themes and Centralized Location Selection.

---

## 1. Overview of Changes

This update introduces full Store / Shop & Geolocation Discovery support to the Flutter mobile application, matching enterprise-grade production standards with Bloc/Cubit state management, comprehensive error handling, and modern UI/UX design.

---

## 2. Architecture & Components Added

### 2.1 State Management (Cubits) & Repository
- **`StoreRepository`** (`lib/features/store/repository/store_repository.dart`):
  - `getStores()`: Fetches nearby stores with coordinates, radius, location hierarchy, search keyword, and sort options.
  - `getStoreDetail()`: Fetches complete store profile, distance, active item catalog, and ratings/reviews.
  - `setupStore()`: Multipart form data submission for store creation and updates (supporting logo and banner file uploads).
  - `getMyStore()`: Retrieves authenticated user's existing store profile.
  - `toggleStoreStatus()`: Instantly toggles active/inactive store visibility.
- **`NearbyStoresCubit`**: Handles loading, pagination, sorting, and radius filtering for nearby stores.
- **`StoreDetailsCubit`**: Fetches and caches store profile details and catalog.
- **`StoreSetupCubit`**: Manages store setup/edit form submission and status updates.
- **`MyStoreCubit`**: Central session cubit tracking the user's store state and synchronizing across profile screens.

### 2.2 Screens & Widgets
- **`NearbyStoresScreen`** (`lib/features/store/screens/nearby_stores_screen.dart`):
  - Search bar with debouncing.
  - Filter and sort bottom sheet.
  - Radius slider.
  - Location chip linked to centralized `Routes.locationScreen`.
  - Responsive store card list with pull-to-refresh and infinite scroll pagination.
- **`StoreDetailsScreen`** (`lib/features/store/screens/store_details_screen.dart`):
  - Dynamic sliver app bar with cover banner and store logo avatar.
  - Official verification badge and distance counter.
  - Tabbed interface:
    1. **Items**: Grid of active classified listings by this store.
    2. **About**: Business description, address, map link, working hours table, and contact buttons (Call, Email).
    3. **Reviews**: Customer reviews with star rating breakdown.
- **`StoreSetupScreen`** (`lib/features/store/screens/store_setup_screen.dart`):
  - Cover banner and logo image pickers with live previews.
  - Centralized location picker returning `LeafLocation`.
  - Working days multi-select filter chips.
  - Pre-populates existing store data automatically when editing.
- **`StoreCardWidget`** (`lib/features/store/widgets/store_card_widget.dart`):
  - Reusable store card with banner, avatar, verified badge, rating summary, and distance indicator.

---

## 3. Bug Fixes & Improvements

1. **`AppButton` Assertion Error Fix**: Resolved `AppButton requires exactly one of title or child` assertion failure during loading state by ensuring mutually exclusive arguments.
2. **Sort Parameter Alignment**: Fixed sort parameter values sent to `/api/get-stores` to match backend supported keys (`nearest`, `top_rated`, `newest`, `popular`).
3. **JSON Response Parsing**: Resolved type casting exception in `StoreRepository.getStoreDetail` to safely parse map responses.
4. **My Store Edit State Pre-population**: Fixed issue where clicking "My Store" after creating a store opened a blank form instead of populating existing store details for editing.
5. **Verified Store Protection**: Added official verified banner badge and locked all form inputs to `readOnly`, disabled image/location pickers, and hid the save button when `isVerified == true`.
6. **Localization**: Added full set of store-related translation keys to `assets/languages/language.json`.