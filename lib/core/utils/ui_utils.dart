import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/widgets/surfaces/login_required_bottom_sheet.dart';
import 'package:flutter/material.dart';

class UiUtils {
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    double? height,
    bool isDismissible = true,
    bool isDraggable = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      enableDrag: isDraggable,
      constraints: BoxConstraints(
        maxHeight: height ?? MediaQuery.sizeOf(context).height * .8,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) =>
          Padding(padding: MediaQuery.viewInsetsOf(context), child: child),
    );
  }

  static void checkUser({
    required Function() onNotGuest,
    required BuildContext context,
  }) {
    if (AppSession.isAuthenticated) {
      onNotGuest.call();
    } else {
      LoginRequiredBottomSheet.show(context);
    }
  }
}
