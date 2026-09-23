import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ToastMessage extends StatefulWidget {
  const ToastMessage({
    required this.message,
    required this.duration,
    super.key,
  });

  final String message;

  /// How long the toast stays fully visible before it starts sliding away.
  final Duration duration;

  @override
  State<ToastMessage> createState() => _ToastMessageState();
}

class _ToastMessageState extends State<ToastMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..forward();

  late final Animation<double> slideAnimation =
      Tween<double>(begin: -0.5, end: 1).animate(
        CurvedAnimation(
          parent: animationController,
          curve: Curves.easeInOutCirc,
        ),
      );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) animationController.reverse();
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: slideAnimation,
      builder: (context, child) {
        final width = MediaQuery.sizeOf(context).width;
        final height = MediaQuery.sizeOf(context).height;
        return PositionedDirectional(
          start: width * 0.1,
          bottom: height * 0.07 * slideAnimation.value,
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: FadeTransition(
              opacity: slideAnimation,
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  alignment: AlignmentDirectional.center,
                  width: width * 0.8,
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: context.colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.message,
                    style: context.titleSmall.copyWith(
                      color: context.colorScheme.surface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
