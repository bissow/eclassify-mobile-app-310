import 'package:eClassify/features/company_details/cubits/user_query_cubit.dart';
import 'package:eClassify/core/models/company_details.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (_) => UserQueryCubit(),
        child: const ContactUs(),
      ),
    );
  }
}

class _ContactUsState extends State<ContactUs> {
  final _nameController = TextController(text: AppSession.currentUser?.name);
  final _emailController = TextController(text: AppSession.currentUser?.email);
  final _subjectController = TextController();
  final _messageController = TextController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final hasValidFields =
        _nameController.validate() &
        _emailController.validate() &
        _subjectController.validate() &
        _messageController.validate();
    if (!hasValidFields) return;

    context.read<UserQueryCubit>().sendUserQuery(
      name: _nameController.text,
      email: _emailController.text,
      subject: _subjectController.text,
      message: _messageController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final companyDetails = Constant.systemSettings.companyDetails;
    final contactUsContent = companyDetails.pages.getPageFromType(
      CompanyPage.contactUs,
    );
    return AppScaffold(
      appBar: AppBar(
        title: Text(CompanyPage.contactUs.label.translate(context)),
      ),
      body: SingleChildScrollView(
          padding: context.bodyPadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (contactUsContent.isNotNullAndNotEmpty)
                HtmlWidget(contactUsContent!),
              16.vGap,
              Text(
                'contactUsTitle'.translate(context),
                style: context.titleLarge,
              ),
              8.vGap,
              Text(
                'contactUsSubTitle'.translate(context),
                style: context.bodyMedium,
              ),
              8.vGap,
              _ContactChips(
                contact: companyDetails.companyContactNumbers,
                email: companyDetails.companyEmail,
              ),
              16.vGap,
              CustomTextField(
                controller: _nameController,
                hintKey: 'fullName',
                autoFillHints: const [AutofillHints.name],
              ),
              12.vGap,
              CustomTextField(
                controller: _emailController,
                hintKey: 'emailAddress',
                validators: [EmptyFieldValidator(), EmailValidator()],
                textInputType: TextInputType.emailAddress,
                autoFillHints: const [AutofillHints.email],
              ),
              12.vGap,
              CustomTextField(
                controller: _subjectController,
                hintKey: 'subject',
              ),
              12.vGap,
              CustomTextField(
                controller: _messageController,
                hintKey: 'message',
                minLines: 5,
                maxLines: 100,
              ),
              16.vGap,
              BlocConsumer<UserQueryCubit, UserQueryState>(
                listener: (context, state) {
                  if (state is UserQuerySuccess) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      'contactUsQuerySubmitted'.translate(context),
                    );
                    _subjectController.clear();
                    _messageController.clear();
                  } else if (state is UserQueryFailure) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      ApiErrorHelper.errorMessageFromException(
                        context,
                        state.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return AppButton(
                    variant: AppButtonVariant.filled,
                    onPressed: () => _submit(context),
                    child: state is UserQueryLoading
                        ? LoadingIndicator.inlineDots()
                        : Text('submit'.translate(context)),
                  );
                },
              ),
            ],
          ),
        ),
    );
  }
}

class _ContactChips extends StatelessWidget {
  const _ContactChips({required this.contact, required this.email});

  final List<String> contact;
  final String email;

  Widget _chip(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card.filled(
        color: context.colorScheme.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            spacing: 8,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(icon, color: context.colorScheme.primary),
                ),
              ),
              Text(label, style: context.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _chip(
            context,
            AppIcons.phone,
            'call'.translate(context),
            onTap: () {
              if (contact.length == 1) {
                launchUrlString('tel:${contact.first}');
              } else {
                UiUtils.showBottomSheet(
                  context,
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: contact
                          .map(
                            (c) => ListTile(
                              title: Text(c),
                              onTap: () => launchUrlString('tel:$c'),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                );
              }
            },
          ),
        ),
        Expanded(
          child: _chip(
            context,
            AppIcons.envelopeSimple,
            'email'.translate(context),
            onTap: () {
              launchUrlString('mailto:$email');
            },
          ),
        ),
      ],
    );
  }
}
