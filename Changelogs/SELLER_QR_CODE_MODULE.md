# Changelog: Seller QR Code Standee & Public Catalog Module (Flutter Mobile App)

**Date:** 2026-09-10  
**Project:** `eclassify-mobile-app` (Flutter 3.47 / Dart 3.13)

---

## 1. Overview

Implemented the full native Flutter mobile integration for the **Seller Store QR Code Feature**. Shoppers can scan counter standees, posters, and flyers using the integrated, high-performance in-app QR scanner or open QR deep links (`eclassify://store-qr/{token}` and `https://bissow.com/store-qr/{token}`).

The scanned store catalog features an automatic GPS location mismatch check using `Geolocator`. If the customer is browsing an out-of-area seller (beyond the configured distance threshold), an informative, dismissible amber warning notice is displayed with distance in kilometers without interrupting catalog browsing.

For merchants, a dedicated **Store QR Standee** screen was introduced in the Profile menu allowing subscribed sellers to customize standee accent colors, configure custom taglines, preview their counter standee, and directly download or share print-ready PDF standees.

---

## 2. Modified & Created Files

### Dependencies & Manifests
- **`pubspec.yaml`** [MODIFIED]
  - Added `mobile_scanner: ^7.4.1` for camera-based QR code scanning and photo gallery image analysis.
- **`android/app/src/main/AndroidManifest.xml`** [MODIFIED]
  - Added intent-filter path patterns for `/store-qr/.*` and `/.*/store-qr/.*`.
  - Added custom scheme intent-filter for `eclassify://store-qr/*`.
- **`ios/Runner/Info.plist`** [MODIFIED]
  - Updated `NSCameraUsageDescription` to explicitly cover seller store QR scanning.

### Deep Linking Architecture
- **`lib/core/deep_link/deep_link_type.dart`** [MODIFIED]
  - Added `storeQr('store-qr')` enum value.
  - Added custom scheme detection for `eclassify://store-qr/*`.
- **`lib/core/deep_link/deep_link_target.dart`** [MODIFIED]
  - Added `StoreQrDeepLink` class extending `DeepLinkTarget`.
  - Added `DeepLinkType.storeQr` parser in `DeepLinkTarget.parse()`.
- **`lib/core/deep_link/deep_link_listener.dart`** [MODIFIED]
  - Added route handling for `StoreQrDeepLink` navigating to `Routes.sellerStoreQr`.

### Network & Data Models
- **`lib/core/network/api_endpoints.dart`** [MODIFIED]
  - Added endpoints:
    - `sellerQrEligibility`: `'seller-qr/eligibility'`
    - `sellerMyQr`: `'seller-qr/my-qr'`
    - `sellerQrGenerateOrUpdate`: `'seller-qr/generate-or-update'`
    - `sellerQrSettings`: `'seller-qr/settings'`
    - `sellerQrStore`: `'seller-qr/store'`
    - `sellerQrDownload`: `'seller-qr/download'`
- **`lib/features/store/models/seller_qr_model.dart`** [NEW]
  - `LocationWarningModel`: represents GPS distance check, distance badge, and store location.
  - `SellerQrCodeModel`: represents QR token, custom tagline, theme color, scan count, and raw SVG.
  - `SellerQrEligibilityModel`: checks seller store ownership and package entitlement (`allows_seller_qr_code`).
- **`lib/features/store/repository/store_repository.dart`** [MODIFIED]
  - Added `getStoreByQr()`: fetches store catalog, location warning, and items.
  - Added `checkSellerQrEligibility()`: checks merchant package entitlement.
  - Added `getMySellerQr()`: retrieves seller's active QR code.
  - Added `generateOrUpdateSellerQr()`: updates custom tagline and theme color.

### State Management (Cubits)
- **`lib/features/store/cubits/seller_store_qr_cubit.dart`** [NEW]
  - Manages store catalog fetching, silent GPS acquisition via `Geolocator`, search, category filters, and pagination.
- **`lib/features/store/cubits/seller_qr_standee_cubit.dart`** [NEW]
  - Manages standee entitlement verification, loading configuration, updating colors/tagline, and PDF downloads.

### Screens & Widgets
- **`lib/features/store/screens/qr_scanner_screen.dart`** [NEW]
  - High-performance camera scanner with animated laser beam, flashlight toggle, gallery photo analyzer, and automatic token parser.
- **`lib/features/store/screens/seller_store_qr_screen.dart`** [NEW]
  - Dedicated public store catalog screen with dismissible location mismatch warning banner, store hero card, search bar, category chips, and product grid.
- **`lib/features/store/screens/seller_qr_standee_screen.dart`** [NEW]
  - Merchant dashboard screen featuring an interactive UPI standee mockup preview, color presets, custom tagline field, size dropdown, and printable PDF download.
- **`lib/features/home/screens/widgets/home_search.dart`** [MODIFIED]
  - Added quick-access QR Scanner icon button next to nearby stores button.
- **`lib/features/profile/screens/profile_tab_screen.dart`** [MODIFIED]
  - Added "Store QR Standee" menu item under Seller options.
  - Added "Scan Store QR Code" menu item in General tools.
- **`lib/core/constants/app_icons.dart`** [MODIFIED]
  - Added `AppIcons.qrCode = PhosphorIcons.qrCode`.
- **`lib/app/routes.dart`** [MODIFIED]
  - Registered `Routes.qrScanner`, `Routes.sellerStoreQr`, and `Routes.sellerQrStandee`.

## 4. Updates & Bug Fixes (v3.2.1)

### 4.1 Fixed Subscription Eligibility Parsing
- In `lib/features/store/models/seller_qr_model.dart`:
  - Updated `SellerQrEligibilityModel.fromJson` to check `json['is_eligible'] ?? json['eligible']` with integer/boolean tolerance (`== 1 || == true`).
  - Subscribed merchants now seamlessly pass the eligibility check and open Standee Studio without false "Upgrade Required" dialogs.

### 4.2 Robust Standee & QR Code Field Mapping
- In `lib/features/store/models/seller_qr_model.dart`:
  - Updated `SellerQrCodeModel.fromJson` to map fallback keys (`token` / `qr_code_token`, `custom_tagline` / `tagline`, `custom_color` / `primary_color`, `format` / `qr_style`, `svg_raw` / `qr_base64_svg`).
  - Standee mockup now renders store avatar, verified badge, and SVG QR code immediately without relying on secondary update calls.

## 5. Updates & Bug Fixes (v3.2.2)

### 5.1 Standee Download Resilience
- **Modified Files**:
  - `lib/features/store/screens/seller_qr_standee_screen.dart`
  - `lib/features/store/models/seller_qr_model.dart`
- **Changes**:
  - In `_downloadStandee()`, validated non-empty token presence, added user feedback if standee is not yet saved, and wrapped external launcher calls with error handling.
  - Updated download button text dynamically to `Download ${_selectedFormat.toUpperCase()}` and ensured token resolution via `qrCode?.token ?? qrCode?.qrCodeToken`.

### 5.2 UPI Standee Preview Visual Consistency
- **Modified Files**:
  - `lib/features/store/screens/seller_qr_standee_screen.dart`
  - `lib/features/store/models/seller_qr_model.dart`
- **Changes**:
  - In `_buildStandeePreview`, refactored mockup layout to mirror `standee_template.blade.php`:
    - Top accent border (8px)
    - Top pill badge: `qrCode?.badgeText ?? 'DIGITAL STORE & CATALOG'`
    - Header title and custom tagline
    - QR Code container with accent border and scan action badge pill (`SCAN TO VIEW ALL ADS & OFFERS`)
    - Store details box with store avatar, verified tick, and location
    - Standee footer branding with `qrCode?.defaultFooterText ?? 'Powered by Bissow.com'`

### 5.3 Catalog Platform Footer Branding
- **Modified Files**:
  - `lib/features/store/screens/seller_store_qr_screen.dart`
- **Changes**:
  - Added a platform footer branding sliver at the end of the public store catalog.

---

## 6. Verification
- Ran `flutter analyze lib/features/store/`: 0 issues found across all store models, cubits, and screens.
- Verified compilation and clean diagnostics across all touched files.

---

## 7. Updates & Bug Fixes (v3.2.3)

### 7.1 Fixed Store QR Catalog Items List Display ("1 Item in Catalog" Issue)
- **Problem**: In `StoreRepository.getStoreByQr()`, items were parsed using `Item.fromJson`. Because the public catalog endpoint returns lightweight list item representations (which omit heavy details like `coordinates`, `contact`, full `category` object, etc.), calling `Item.fromJson` threw type cast exceptions on null required fields, which `JsonHelper.parseList` caught, resulting in an empty items list (`state.items = []`) even when `state.total = 1`. Furthermore, `responseData['items']['data']` was parsed assuming only a `List`, failing if formatted as a single object.
- **Solution**:
  - In `lib/features/store/repository/store_repository.dart`:
    - Updated return type of `getStoreByQr()` from `List<Item>` to `List<ItemPreview>`.
    - Made `rawItems` extraction robust to both `List` and `Map` data payloads.
    - Used `ItemPreview.fromJson` to parse each catalog item safely without required-field exceptions.
  - In `lib/features/store/cubits/seller_store_qr_cubit.dart`:
    - Updated `SellerStoreQrSuccess` and `loadMore()` to hold and manipulate `List<ItemPreview> items`.
  - In `lib/features/store/screens/seller_store_qr_screen.dart`:
    - Removed redundant manual instantiation of `ItemPreview` and passed `state.items[index]` directly into `ItemCard.grid(item: item, onTap: ...)`.
    - Removed unused imports to ensure 100% clean `flutter analyze`.

---

## 8. Updates & Improvements (v3.2.4)

### 8.1 Custom SEO URL Slug Configuration in App
- **Modified Files**:
  - `lib/features/store/models/seller_qr_model.dart`
  - `lib/features/store/repository/store_repository.dart`
  - `lib/features/store/cubits/seller_qr_standee_cubit.dart`
  - `lib/features/store/screens/seller_qr_standee_screen.dart`
- **Changes**:
  - Added `customSlug`, `catalogBaseUrl`, `canCustomizeSlug`, and `canCustomizeColors` fields to `SellerQrCodeModel`.
  - Added Custom SEO URL Slug input field with `/store-qr/` prefix in Standee Studio.
  - Sellers can customize their clean store slug directly from the mobile app and submit to `generateOrUpdateSellerQr`.

### 8.2 Admin Permission Synchronization
- **Modified Files**:
  - `lib/features/store/screens/seller_qr_standee_screen.dart`
- **Changes**:
  - Disabled slug and color customization when locked by the administrator, displaying visual `"Locked by Admin"` / `"Managed by Admin"` status badges.

### 8.3 Verification
- Ran `flutter analyze lib/features/store/`: 0 issues found across all store models, cubits, repositories, and screens.

---

## 9. Updates & Bug Fixes (v3.2.5)

### 9.1 Fixed Store QR Standee Assertion Failure (`A borderRadius can only be given on borders with uniform colors`)
- **Problem**: When opening `SellerQrStandeeScreen`, the QR standee mockup card was not visible and triggered an assertion error during paint:
  ```
  The following assertion was thrown during paint():
  A borderRadius can only be given on borders with uniform colors.
  The following is not uniform: BorderSide.color
  Container: seller_qr_standee_screen.dart:339:14
  ```
  The standee container combined `borderRadius: BorderRadius.circular(20)` with a non-uniform `Border(top: BorderSide(color: accentColor, width: 8), left: ..., right: ..., bottom: ...)`. Flutter disallows non-uniform border colors when `borderRadius` is set.
- **Solution**:
  - Updated outer container decoration in `lib/features/store/screens/seller_qr_standee_screen.dart` to use a uniform border: `Border.all(color: Colors.grey.shade200, width: 1)`.
  - Moved the top 8px accent color bar into the `ClipRRect(borderRadius: BorderRadius.circular(19))` child column (`Container(height: 8, width: double.infinity, color: accentColor)`), preserving the exact rounded accent visual cleanly without triggering paint assertions.
  - Added `_buildQrCodeWidget` to safely handle both raw SVG XML strings and base64-encoded SVG data URIs (`data:image/svg+xml;base64,...`) with fallback placeholder icons.
  - Enhanced `SellerQrCodeModel.fromJson` in `lib/features/store/models/seller_qr_model.dart` to automatically decode base64 SVGs to raw SVG strings.

### 9.2 Fixed Action Buttons Hidden Behind System Navigation Keys
- **Problem**: The "Download" and "Save Standee" action buttons were at the bottom of the scroll view without bottom `SafeArea` padding. On Android devices with a 3-button navigation bar or gesture pill, the system navigation keys directly obstructed and overlapped the buttons.
- **Solution**:
  - Moved the action buttons into `Scaffold.bottomNavigationBar` wrapped in `SafeArea(top: false, child: ...)`.
  - Added elevation and top border separation so the buttons remain permanently pinned, fully visible, and automatically positioned above the Android navigation bar.
  - Wrapped `Scaffold.body` in `SafeArea(top: false)` to prevent scroll view content overlap.

### 9.3 Verification
- Ran `flutter analyze lib/features/store/`: 0 issues found across all store models, cubits, repositories, and screens.

---

## 10. Updates & Improvements (v3.2.5)

### 10.1 Resilient API Response Handling in `SellerQrCodeModel`
- **Modified Files**:
  - `lib/features/store/models/seller_qr_model.dart`
- **Changes**:
  - Enhanced `SellerQrCodeModel.fromJson()` factory to handle both root-level maps and nested payloads (`rawJson['qr_code']` or `rawJson['data']['qr_code']`), ensuring save operations on both mobile and web backend controllers parse reliably.

### 10.2 Footer Branding Logo Support in Standee Preview
- **Modified Files**:
  - `lib/features/store/screens/seller_qr_standee_screen.dart`
- **Changes**:
  - Rendered `qrCode.footerLogoUrl` alongside `defaultFooterText` in the live standee preview mockup, matching the exact layout of the Next.js web preview and PDF downloads.
