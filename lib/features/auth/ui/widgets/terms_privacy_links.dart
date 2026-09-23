import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/models/company_details.dart';
import 'package:eClassify/core/widgets/text/linked_text.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

/// [LinkedText] pre-wired with the `{terms}`/`{privacy}` tags pointing at
/// [Routes.companyPage] — shared by [TermsAndConditionsWidget] and
/// [TermsAcceptanceDialog] so both render the same tappable links off the
/// same template string.
class TermsPrivacyLinks extends StatelessWidget {
  const TermsPrivacyLinks({
    required this.template,
    this.style,
    this.textAlign = TextAlign.start,
    super.key,
  });

  /// Text containing `{terms}`/`{privacy}` placeholders.
  final String template;
  final TextStyle? style;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return LinkedText(
      template: template,
      tags: {
        'terms': LinkedTextTag(
          text: "termsOfService".translate(context),
          onTap: () => Navigator.pushNamed(
            context,
            Routes.companyPage,
            arguments: CompanyPage.termsAndConditions,
          ),
        ),
        'privacy': LinkedTextTag(
          text: "privacyPolicy".translate(context),
          onTap: () => Navigator.pushNamed(
            context,
            Routes.companyPage,
            arguments: CompanyPage.privacyPolicy,
          ),
        ),
      },
      style: style,
      textAlign: textAlign,
    );
  }
}
