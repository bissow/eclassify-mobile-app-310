import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/auth/cubits/email_password_reset_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/cubits/phone_password_reset_cubit.dart';
import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/surfaces/bottom_sheet_skeleton.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/phone_input.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordBottomSheet {
  static void show(
    BuildContext context, {
    required bool isForEmail,
    String? email,
    Contact? contact,
  }) {
    // Captured from the calling context (which lives under AuthScreen's
    // MultiBlocProvider) rather than created inside the sheet — a
    // showModalBottomSheet subtree is disposed on pop, which would close
    // any cubit created there right as the OTP screen it's pushed to still
    // needs it.
    final emailCubit = context.read<EmailPasswordResetCubit>();
    final phoneCubit = context.read<PhonePasswordResetCubit>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: emailCubit),
            BlocProvider.value(value: phoneCubit),
          ],
          child: _SheetContent(
            isForEmail: isForEmail,
            email: email,
            contact: contact,
          ),
        );
      },
    );
  }
}

class _SheetContent extends StatefulWidget {
  const _SheetContent({required this.isForEmail, this.email, this.contact});

  final bool isForEmail;
  final String? email;
  final Contact? contact;

  @override
  State<_SheetContent> createState() => _SheetContentState();
}

class _SheetContentState extends State<_SheetContent> {
  late final TextController _emailController = TextController(
    text: widget.email,
  );
  late final PhoneInputController _phoneInputController = PhoneInputController(
    contact: widget.contact,
  );

  @override
  void dispose() {
    _emailController.dispose();
    _phoneInputController.dispose();
    super.dispose();
  }

  Widget _emailVerificationButtonChild() {
    return BlocConsumer<EmailPasswordResetCubit, EmailPasswordResetState>(
      listener: (context, state) {
        if (state is EmailPasswordResetSuccess) {
          Navigator.of(context).pop();
          HelperUtils.showSnackBarMessage(
            context,
            'passwordResetMailSent'.translate(context),
          );
        }
        if (state is EmailPasswordResetFailure) {
          HelperUtils.showSnackBarMessage(
            context,
            'failedToSendPasswordResetMail'.translate(context),
          );
        }
      },
      builder: (context, state) {
        if (state is EmailPasswordResetInProgress) {
          return LoadingIndicator.inlineDots();
        } else {
          return Text('verifyEmailAddress'.translate(context));
        }
      },
    );
  }

  Widget _phoneVerificationButtonChild() {
    return BlocConsumer<PhonePasswordResetCubit, OtpFlowState>(
      listener: (context, state) {
        if (state is OtpFlowSent) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(
            Routes.phonePasswordResetOtp,
            arguments: context.read<PhonePasswordResetCubit>(),
          );
        }
        if (state is PhoneResetOtpFailure) {
          HelperUtils.showSnackBarMessage(
            context,
            ApiErrorHelper.errorMessageFromException(context, state.error),
          );
        }
      },
      builder: (context, state) {
        if (state is OtpFlowSending) {
          return LoadingIndicator.inlineDots();
        } else {
          return Text('sendOTP'.translate(context));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetSkeleton(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 12,
        children: [
          Text(
            'forgotPassword'.translate(context),
            style: context.headlineSmall,
          ),

          if (widget.isForEmail)
            CustomTextField(
              controller: _emailController,
              validators: [EmptyFieldValidator(), EmailValidator()],
              hintKey: 'emailAddress',
            )
          else
            PhoneInput(controller: _phoneInputController),
          AppButton(
            variant: AppButtonVariant.filled,
            size: AppButtonSize.small,
            onPressed: () async {
              if (widget.isForEmail) {
                if (!_emailController.validate()) return;
                context.read<EmailPasswordResetCubit>().resetPassword(
                  email: _emailController.text,
                );
              } else {
                if (!await _phoneInputController.validateAsync()) return;
                context.read<PhonePasswordResetCubit>().sendOtp(
                  contact: _phoneInputController.contact,
                  formattedNumber: _phoneInputController.formattedNumber,
                );
              }
            },
            child: widget.isForEmail
                ? _emailVerificationButtonChild()
                : _phoneVerificationButtonChild(),
          ),
        ],
      ),
    );
  }
}
