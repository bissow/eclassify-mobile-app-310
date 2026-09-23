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
