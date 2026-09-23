# Integration Guide & Changelog: Image Editor & Rich Text Module (Flutter Mobile App)

**Project Name:** Eclassify Mobile App (Flutter SDK >=3.12.0 <4.0.0)  
**Working Directory:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app`  
**Date:** 2026-09-22  
**Version:** 1.1.0  
**Compatibility:** 100% backward-compatible with existing Ad Posting, Media Controller, and Ad Details screens.

---

## 1. Overview & Architecture

This guide provides the complete blueprint and reference implementation for integrating:
1. **Native Flutter Image Editor Screen**: In-place image editing during ad photo selection (camera or gallery) with crop aspect ratios, rotate/flip, adjustments, 7 color filter presets, 8-handle proportional text resizing, and draggable badges without any fragile third-party native C++ dependencies.
2. **Rich Text & Clickable Indian Phone / URL Links**: Rendering rich HTML descriptions, auto-formatting 10-digit Indian phone numbers into interactive `.eclassify-phone-badge` call links, clickable URLs, and theme-aware (Light/Dark) styling.

Use this reference to port or replicate these changes into any subsequent or branched version of the Flutter mobile app.

---

## 2. Modified & Created Files Summary

| # | Action | Relative File Path | Absolute File Path |
|---|---|---|---|
| 1 | **MODIFY** | `assets/languages/language.json` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\assets\languages\language.json` |
| 2 | **MODIFY** | `lib/core/constants/app_icons.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\core\constants\app_icons.dart` |
| 3 | **MODIFY** | `lib/core/utils/collection_notifiers.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\core\utils\collection_notifiers.dart` |
| 4 | **MODIFY** | `lib/features/ad_posting/screens/widgets/media_selection/media_controller.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\ad_posting\screens\widgets\media_selection\media_controller.dart` |
| 5 | **CREATE** | `lib/features/ad_posting/screens/widgets/media_selection/image_editor_screen.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\ad_posting\screens\widgets\media_selection\image_editor_screen.dart` |
| 6 | **MODIFY** | `lib/features/ad_posting/screens/widgets/media_selection/ad_image_widget.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\ad_posting\screens\widgets\media_selection\ad_image_widget.dart` |
| 7 | **MODIFY** | `lib/features/item/models/item.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\item\models\item.dart` |
| 8 | **MODIFY** | `lib/features/advertisement/screens/details/ad_details_screen.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\advertisement\screens\details\ad_details_screen.dart` |
| 9 | **MODIFY** | `lib/features/advertisement/screens/details/widgets/item_description_widget.dart` | `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\advertisement\screens\details\widgets\item_description_widget.dart` |

---

## 3. Step-by-Step Implementation Reference

### File 1: `assets/languages/language.json`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\assets\languages\language.json`
* **Purpose:** Localization strings for image editor tools, presets, badges, and expand toggles.
* **Keys Added:**
  ```json
  "editImage": "Edit Image",
  "crop": "Crop",
  "rotate": "Rotate",
  "filter": "Filter",
  "addText": "Add Text",
  "enterText": "Enter text...",
  "fontSize": "Font Size",
  "textColor": "Text Color",
  "bgColor": "Background Color",
  "badges": "Badges",
  "apply": "Apply",
  "reset": "Reset",
  "saveChanges": "Save Changes",
  "imageEditor": "Image Editor",
  "aspectRatioFree": "Free",
  "aspectRatioSquare": "1:1 Square",
  "aspectRatioStandard": "4:3 Standard",
  "aspectRatioLandscape": "16:9 Landscape",
  "aspectRatioStory": "9:16 Story",
  "aspectRatioClassic": "3:2 Classic",
  "contrast": "Contrast",
  "brightness": "Brightness",
  "saturation": "Saturation",
  "badgeUrgent": "URGENT",
  "badgeBestOffer": "BEST OFFER",
  "badgeVerified": "VERIFIED",
  "badgeFeatured": "FEATURED",
  "badgeSale": "SALE",
  "badgeNegotiable": "NEGOTIABLE",
  "badgeNew": "NEW",
  "readMore": "Read more",
  "readLess": "Read less",
  "seeMore": "See More",
  "seeLess": "See Less"
  ```

---

### File 2: `lib/core/constants/app_icons.dart`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\core\constants\app_icons.dart`
* **Purpose:** Map the crop icon to PhosphorIcons.
* **Addition:**
  ```dart
  static const IconData crop = PhosphorIcons.crop;
  ```

---

### File 3: `lib/core/utils/collection_notifiers.dart`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\core\utils\collection_notifiers.dart`
* **Purpose:** Enable direct indexed assignment on `ListNotifier<T>`.
* **Addition:**
  ```dart
  void operator []=(int index, T item) {
    replaceAt(index, item);
  }
  ```

---

### File 4: `lib/features/ad_posting/screens/widgets/media_selection/media_controller.dart`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\ad_posting\screens\widgets\media_selection\media_controller.dart`
* **Purpose:** Allows modifying an image in-place in the gallery list without clearing other uploaded files.
* **Addition:**
  ```dart
  void updateImageAt(int index, FileResource newImage) {
    if (index >= 0 && index < images.length) {
      final oldFile = images[index];
      images[index] = newImage;
      removeOversizedImage(oldFile.filePath);
      clearError(MediaType.images);
    }
  }
  ```

---

### File 5: `lib/features/ad_posting/screens/widgets/media_selection/image_editor_screen.dart` (NEW / UPDATED)
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\ad_posting\screens\widgets\media_selection\image_editor_screen.dart`
* **Purpose:** Native Flutter Image Editor Screen.
* **Core Technical Capabilities:**
  1. **Interactive Crop Selection Box**:
     - **Custom Painter (`CropOverlayPainter`)**: Renders a dark outer mask (`Color(0x99000000)`), white border, 3x3 rule-of-thirds grid lines, and primary-colored corner accents.
     - **Draggable Selection**: Panning inside the crop rectangle translates `_cropRect` smoothly within canvas boundaries.
     - **4 Draggable Corner Handles**: Positioned at `NW`, `NE`, `SW`, `SE` with 36x36 touch targets and `HitTestBehavior.opaque`.
     - **Opposite-Corner Anchoring**: Resizing anchors strictly to the opposite corner (`SE` anchors to `NW`, `NW` anchors to `SE`, etc.) without visual jumping.
     - **Aspect Ratio & Free Crop**: Adapts to selected ratios (`1:1`, `4:3`, `16:9`, `9:16`, `3:2`) or allows free-form rectangular selection.
     - **High-Performance Native Extraction (`_executeCrop`)**: Temporarily suppresses overlay indicators and uses `ui.PictureRecorder` + `toByteData(format: ui.ImageByteFormat.png)` to bake the selected crop rectangle into a local cache file, updating `_activeImageFile` and clearing image cache.
     - **Crop Toolbar Buttons**: "Apply Crop" (`FilledButton.icon`) and "Reset Crop" (`OutlinedButton.icon`) in `_buildCropTab()`.
  2. **Text Overlays with Direct 8-Handle Resizing**:
     - **Gesture Isolation**: Move pan listener is strictly attached to the text container, preventing gesture arena conflicts with handles.
     - **8 Sibling Handles**: `NW`, `N`, `NE`, `E`, `SE`, `S`, `SW`, `W` with 32x32 touch targets and `HitTestBehavior.opaque`.
     - **Mathematically True Opposite-Corner Anchoring (`_resizeTextLayer`)**: Calculates text dimensions via `TextPainter` and offsets `layer.offset` by `-deltaW * anchorRatio.dx` and `-deltaH * anchorRatio.dy` so that the opposite anchor point remains 100% stationary during dragging.
     - Real-time font size clamping (`12.0` to `72.0`).
     - Text styling: Color swatches, background fill swatches, bold toggle, and double-tap editing.
  3. **Transforms**: 90° rotation quarter turns, horizontal flip, vertical flip via `Matrix4.identity()`.
  4. **Color Matrix**: 4x5 color filter matrix calculating brightness, contrast, and saturation in real-time.
  5. **7 Preset Filters**: Vivid, Warm, Cool, Mono, Vintage, Dramatic, Original.
  6. **Preset Badges**: URGENT, BEST OFFER, VERIFIED, FEATURED, SALE, NEGOTIABLE, NEW.
  7. **Export**: Renders the complete stack using `RepaintBoundary` at `pixelRatio: 2.5` directly to local cache file via `path_provider`, returning a `LocalFileResource`.
  8. **Responsive Layouts & Infinite Size Prevention**: Prevents `RenderFlex` overflow and unbounded constraints by enforcing `mainAxisSize: MainAxisSize.min` on all `Row` widgets placed inside horizontal `SingleChildScrollView` containers, wrapping bottom toolbar buttons in `Expanded`, and constraining slider labels with `SizedBox(width: 70)`.
* **Route Method:**
  ```dart
  static Route<FileResource?> route(FileResource resource) {
    return MaterialPageRoute<FileResource?>(
      builder: (_) => ImageEditorScreen(imageResource: resource),
    );
  }
  ```

---

### File 6: `lib/features/ad_posting/screens/widgets/media_selection/ad_image_widget.dart`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\ad_posting\screens\widgets\media_selection\ad_image_widget.dart`
* **Purpose:** Adds edit buttons to image preview chips and bottom sheets.
* **Changes Made:**
  1. **Add `_openImageEditor` helper:**
     ```dart
     Future<void> _openImageEditor(BuildContext context, MediaController controller, int index) async {
       if (index < 0 || index >= controller.images.length) return;
       final imageResource = controller.images[index];
       final editedResource = await Navigator.of(context).push<FileResource?>(
         ImageEditorScreen.route(imageResource),
       );
       if (editedResource != null) {
         controller.updateImageAt(index, editedResource);
       }
     }
     ```
  2. **Update `_ImagePreview` to accept `onEdit` callback**:
     Renders `AppIcons.pencilSimpleLine` button at `start: -4, top: -6` and enables tapping the image chip to edit.
  3. **Update `AdImageWidget` and `_ImageBottomSheet`**:
     Wire `onEdit: () => _openImageEditor(context, controller, index)`.

---

### File 7: `lib/features/item/models/item.dart`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\item\models\item.dart`
* **Purpose:** Add `formattedDescription` and `descriptionJson` fields to the `Item` model.
* **Changes Made:**
  ```dart
  // In constructor
  formattedDescription = LocalizedString(
    canonical: (json['formatted_description'] ?? json['description']) as String? ?? '',
    translated: (json['translated_item']?['formatted_description'] ?? json['translated_item']?['description']) as String?,
  ),
  descriptionJson = json['description_json'] as String?,

  // Field declarations
  final LocalizedString formattedDescription;
  final String? descriptionJson;
  ```

---

### File 8: `lib/features/advertisement/screens/details/ad_details_screen.dart`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\advertisement\screens\details\ad_details_screen.dart`
* **Purpose:** Pass `formattedDescription` with fallback to `description` to `ItemDescriptionWidget`.
* **Changes Made:**
  ```dart
  ItemDescriptionWidget(
    description: (item?.formattedDescription.localized.isNotEmpty ?? false)
        ? item?.formattedDescription.localized
        : item?.description.localized,
  ),
  ```

---

### File 9: `lib/features/advertisement/screens/details/widgets/item_description_widget.dart`
* **Path:** `c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app\lib\features\advertisement\screens\details\widgets\item_description_widget.dart`
* **Purpose:** Rich HTML and auto-link description widget.
* **Changes Made:**
  - Integrated `HtmlWidget` from `flutter_widget_from_html`.
  - Added regex auto-linkifier converting raw 10-digit Indian numbers to `<a href="tel:+91...">` and URLs to clickable web links.
  - Handled `onTapUrl` via `url_launcher` with `LaunchMode.externalApplication`.
  - Added custom style builder for `.eclassify-phone-badge` supporting Light and Dark modes.
  - Added animated expand/collapse toggle with adaptive surface gradient overlay.

---

## 4. Stability, Layout & Rotation Enhancements (Latest Updates)

### A. Resolution of RenderFlex Infinite Layout Error
* **Root Cause:** In `lib/core/theme/app_theme.dart`, the global theme defined `outlinedButtonTheme` and `filledButtonTheme` with `minimumSize: Size(double.maxFinite, 48)`. When buttons in `_buildRotateTab()` and `_buildCropTab()` were placed within horizontal `Row` or `SingleChildScrollView` without an explicit size override, they requested infinite width (`double.maxFinite`), crashing the layout with `RenderFlex object was given an infinite size during layout`.
* **Fix Applied:** Explicitly defined `minimumSize: const Size(0, 42)` (or `Size(0, 40)`) and customized padding on all buttons in `_buildRotateTab()`, `_buildCropTab()`, `_buildTextTab()`, and dialog action buttons.

### B. High-Fidelity Rotation & Phosphor Icon Integration
* **Icon Registry (`app_icons.dart`):** Registered `arrowCounterClockwise`, `arrowsHorizontal`, and `arrowsVertical` mapped to their official `PhosphorIcons` counterparts.
* **Dart Modulo Calculation:** Changed counter-clockwise rotation to `(_rotationQuarterTurns + 3) % 4` and clockwise rotation to `(_rotationQuarterTurns + 1) % 4` to prevent negative modulo results in Dart.
* **Aspect-Ratio & RotatedBox Viewport:** Replaced raw `Transform(rotateZ)` with `RotatedBox(quarterTurns: _rotationQuarterTurns)` combined with dynamically computed `_effectiveAspectRatio` (inverting width/height when rotated 90° or 270°). This guarantees zero image clipping, zero black letterboxing, and automatic alignment of the crop box overlay.

---

## 5. Verification & Testing

To verify the Flutter mobile app:
```bash
cd c:\Users\nilan\Downloads\Eclassify\eclassify-mobile-app

# 1. Run Dart static analysis
dart analyze lib/features/ad_posting/screens/widgets/media_selection/image_editor_screen.dart lib/core/constants/app_icons.dart

# Result: No issues found!
```
