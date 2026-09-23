import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/widgets/feedback/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';

class HelperUtils {
  /// Shows a toast-style message via [Overlay] rather than [ScaffoldMessenger]
  /// so it's available even where there's no enclosing [Scaffold] (e.g. modal
  /// bottom sheets), and won't shift a [FloatingActionButton] or clip against
  /// a [BottomNavigationBar] the way a [SnackBar] does.
  static void showSnackBarMessage(
    BuildContext context,
    String message, {
    int messageDuration = 3,
  }) {
    final overlayState = Overlay.of(context);
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => ToastMessage(
        message: message,
        duration: Duration(seconds: messageDuration),
      ),
    );

    overlayState.insert(overlayEntry);
    Future.delayed(
      Duration(seconds: messageDuration) + const Duration(milliseconds: 500),
      overlayEntry.remove,
    );
  }

  static double lerpHeight({
    required double screenHeight,
    required double minHeight,
    required double maxHeight,
    required double minScreen,
    required double maxScreen,
  }) {
    // Normalize screen height to 0–1
    final t = ((screenHeight - minScreen) / (maxScreen - minScreen)).clamp(
      0.0,
      1.0,
    );

    // Lerp between min/max height
    return lerpDouble(minHeight, maxHeight, t)!;
  }

  static String getFormattedNumber(Contact contact) {
    final mobile = contact.number;
    String? pCode = contact.callingCode.isEmpty ? null : contact.callingCode;
    String? rCode = contact.regionCode.isEmpty ? null : contact.regionCode;

    // Case 1: Both null, use defaults
    if (pCode == null && rCode == null) {
      pCode = AppConfig.defaultPhoneCode;
      rCode = AppConfig.defaultCountryCode;
    }

    // Case 2: regionCode is present (either originally or via default)
    if (rCode != null) {
      final countries = CountryManager().countries;
      final country = countries.firstWhereOrNull(
        (element) => element.countryCode.toUpperCase() == rCode!.toUpperCase(),
      );

      if (country != null) {
        try {
          final formatted = formatNumberSync(
            mobile,
            country: country,
            inputContainsCountryCode: false,
          );
          return normalizeNumber('${country.phoneCode} $formatted');
        } catch (e) {
          // Fallback if formatting fails
          return normalizeNumber('${pCode ?? country.phoneCode} $mobile');
        }
      }
    }

    // Case 3: regionCode is null (or not found) but phoneCode is available
    if (pCode != null) {
      return normalizeNumber('$pCode $mobile');
    }

    // Final fallback
    return normalizeNumber(mobile);
  }

  static String normalizeNumber(String mobile) {
    mobile = mobile.replaceFirst(RegExp(r'^\++'), '+'); // collapse multiple +
    if (!mobile.startsWith('+')) {
      mobile = '+$mobile';
    }
    return mobile;
  }

  static String? getPhoneCodeFromRegionCode(String? regionCode) {
    if (regionCode == null) return null;
    final countries = CountryManager().countries;
    return countries
        .firstWhereOrNull(
          (c) => c.countryCode.toLowerCase() == regionCode.toLowerCase(),
        )
        ?.phoneCode;
  }

  static String formattedSalaryRange(String minimum, String maximum) {
    final min = num.tryParse(minimum);
    final max = num.tryParse(maximum);
    if (min == null && max == null) {
      return '';
    } else if (min == null) {
      return 'Up to $maximum';
    } else if (max == null) {
      return 'From $minimum';
    } else {
      return '$minimum - $maximum';
    }
  }
}
