import 'package:eClassify/features/auth/ui/widgets/terms_privacy_links.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';

class TermsAndConditionsWidget extends StatelessWidget {
  /// If true, a checkbox is shown before the text.
  final bool showCheckbox;

  /// The current checked state for the checkbox. Only used when [showCheckbox] is true.
  final bool? isChecked;

  /// Called whenever the checkbox value changes. Must be provided when [showCheckbox] is true.
  final ValueChanged<bool?>? onCheckboxChanged;

  const TermsAndConditionsWidget({
    super.key,
    this.showCheckbox = false,
    this.isChecked,
    this.onCheckboxChanged,
  }) : assert(
         !showCheckbox || onCheckboxChanged != null,
         'onCheckboxChanged must not be null if showCheckbox is true',
       );

  @override
  Widget build(BuildContext context) {
    return BottomActionBar(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showCheckbox)
            _buildCheckboxRow(context)
          else
            _buildTextBlock(context),
        ],
      ),
    );
  }

  /// Builds the checkbox + text row for the signup screen.
  Widget _buildCheckboxRow(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: isChecked ?? false,
            activeColor: context.colorScheme.primary,
            onChanged: onCheckboxChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          _buildTextBlock(context),
        ],
      ),
    );
  }

  /// The terms text with tappable links, positioned wherever the translated
  /// `bySigningUpLoggingIn` string places the `{terms}`/`{privacy}` tags.
  Widget _buildTextBlock(BuildContext context) {
    return TermsPrivacyLinks(
      template: "bySigningUpLoggingIn".translate(context),
      style: context.bodySmall.muted(context),
      textAlign: TextAlign.center,
    );
  }
}
