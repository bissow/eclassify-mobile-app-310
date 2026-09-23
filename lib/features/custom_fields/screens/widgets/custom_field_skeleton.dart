import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/custom_fields/screens/custom_fields_controller.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

class CustomFieldSkeleton extends StatefulWidget {
  const CustomFieldSkeleton({
    super.key,
    required this.field,
    required this.child,
  });

  final CustomField field;
  final Widget child;

  @override
  State<CustomFieldSkeleton> createState() => _CustomFieldSkeletonState();
}

class _CustomFieldSkeletonState extends State<CustomFieldSkeleton> {
  CustomFieldsController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = CustomFieldsControllerProvider.maybeOf(
      context,
    )?.controller;
    if (identical(controller, _controller)) return;
    _controller?.revealNotifier.removeListener(_onReveal);
    _controller = controller;
    _controller?.revealNotifier.addListener(_onReveal);
  }

  @override
  void dispose() {
    _controller?.revealNotifier.removeListener(_onReveal);
    super.dispose();
  }

  void _onReveal() {
    final controller = _controller;
    if (controller == null ||
        controller.revealNotifier.value != widget.field.id) {
      return;
    }
    // Errors set by validate() render in this same frame (text field error
    // lines add height above), so scroll after layout has settled.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.1,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
      controller.revealNotifier.value = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final provider = CustomFieldsControllerProvider.maybeOf(context);
    final controller = provider?.controller;
    final isDefaultLanguage = provider?.isDefaultLanguage ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 4,
          children: [
            if (field.image.isNotNullAndNotEmpty)
              SizedBox.square(
                dimension: 28,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: CustomImage(
                      src: field.image,
                      size: Size.square(20),
                      fit: BoxFit.scaleDown,
                    ),
                  ),
                ),
              ),
            Text(field.name.localized, style: context.labelLarge),
            if (field.isRequired && isDefaultLanguage)
              Text('*', style: context.labelLarge.withColor(Colors.red)),
          ],
        ),
        8.vGap,
        widget.child,
        2.vGap,
        // If the field is not a text field, show the error message
        // Because the TextboxField displays the error UI using TextField's property
        // we avoid showing it here
        if (controller != null && field is! TextboxField)
          ListenableBuilder(
            listenable: controller.errorNotifier,
            builder: (context, child) {
              if (!controller.errorNotifier.containsKey(field.id)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 12),
                child: Text(
                  controller.errorNotifier[field.id]?.translate(context) ?? '',
                  style: context.labelSmall.withColor(
                    context.colorScheme.error,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
