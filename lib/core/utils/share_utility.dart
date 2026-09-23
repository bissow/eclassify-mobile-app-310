import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/tap_guard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// The shareable deep link for this target, keeping the URL shape defined
/// once alongside the targets themselves rather than scattered as raw
/// type/value strings at each call site.
extension ShareableLink on DeepLinkTarget {
  String get shareUrl {
    final path = [
      AppSession.currentLanguageCode.toLowerCase(),
      type.path,
      value,
    ].join('/');
    return '${AppConfig.shareDomain}/$path';
  }

  String get shareText {
    return switch (this) {
      ItemDeepLink() => 'shareItemMessage',
      ReelDeepLink() => 'shareItemMessage',
      SellerDeepLink() => 'shareUserMessage',
      BlogDeepLink() => 'shareBlogMessage',
      _ => throw UnimplementedError(),
    };
  }
}

typedef _ShareAction = ({
  IconData icon,
  String label,
  Future<void> Function(BuildContext context, DeepLinkTarget target) onTap,
});

class ShareUtility {
  ShareUtility._();

  static final List<_ShareAction> _actions = [
    (icon: AppIcons.copy, label: "copylink", onTap: _copyLink),
    (icon: AppIcons.shareNetwork, label: "share", onTap: _shareLink),
  ];

  static Future<void> _copyLink(
    BuildContext context,
    DeepLinkTarget target,
  ) async {
    await Clipboard.setData(ClipboardData(text: target.shareUrl));
    Navigator.pop(context);
    HelperUtils.showSnackBarMessage(context, "copied".translate(context));
  }

  static Future<void> _shareLink(
    BuildContext context,
    DeepLinkTarget target,
  ) async {
    final box = context.findRenderObject() as RenderBox?;
    final text = "${target.shareText.translate(context)}:\n${target.shareUrl}.";
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  /// Shows a bottom sheet with copy-link and share actions for [target].
  static void share(BuildContext context, DeepLinkTarget target) {
    final guard = TapGuard();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final action in _actions)
                ListTile(
                  leading: Icon(action.icon),
                  title: Text(action.label.translate(context)),
                  onTap: () => guard.run(() => action.onTap(context, target)),
                ),
            ],
          ),
        );
      },
    );
  }
}
