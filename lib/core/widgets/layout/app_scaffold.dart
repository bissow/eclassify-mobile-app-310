import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';

/// The one place that knows about the bottom of the screen.
///
/// Feature screens never write `SafeArea` or set a scroll view's vertical
/// padding; they use this instead of [Scaffold] and get, by construction:
///
/// * [bottomAction] — a button (or row of buttons) pinned below the body,
///   padded by [Constant.pagePadding] plus the system inset. Pass the bare
///   widget; nothing else.
/// * Scroll views in [body] with `padding: null` end
///   [Constant.verticalPadding] above the bottom action or, without one,
///   above the system inset — and scroll under both. Flutter's scroll views
///   consume the ambient `MediaQuery.padding` as scroll padding, so this
///   widget just sets it. Non-scrolling bodies read the same value through
///   `SafeArea` / `MediaQuery.paddingOf`.
///
/// [bottomNavigationBar] is still available for bars that own their own
/// layout (main tabs, chat composer, ad-posting step buttons); it is passed
/// through unchanged and the body is padded exactly as with [bottomAction].
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    this.appBar,
    this.bottomAction,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.resizeToAvoidBottomInset,
    this.extendBody = false,
    super.key,
  }) : assert(
         bottomAction == null || bottomNavigationBar == null,
         'Use either bottomAction or bottomNavigationBar, not both',
       );

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomAction;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool? resizeToAvoidBottomInset;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBody: extendBody,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomAction != null
          // A custom scaffold colour (splash, full-bleed screens) carries
          // into the bar so it doesn't read as a separate strip.
          ? BottomActionBar(color: backgroundColor, child: bottomAction!)
          : bottomNavigationBar,
      body: Builder(
        builder: (context) {
          // Scaffold has already set the body's bottom padding to what the
          // body must clear: the system inset with no bar, 0 under a normal
          // bar, or the bar's height with extendBody. Add the resting gap
          // on top of that rather than replacing it.
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              padding: media.padding.copyWith(
                bottom: media.padding.bottom + Constant.verticalPadding,
              ),
            ),
            // Without an app bar the body would start under the status
            // bar; the app bar otherwise consumes that inset itself.
            child: body,
          );
        },
      ),
    );
  }
}

/// Pinned bottom container for actions: page padding plus the system inset,
/// always both. Used by [AppScaffold.bottomAction]; reach for it directly
/// only inside widgets that are themselves a bottom bar.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({required this.child, this.color, super.key});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color ?? context.colorScheme.secondary,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: Constant.pagePadding.copyWith(
            top: Constant.verticalPadding / 2,
            bottom: Constant.verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
