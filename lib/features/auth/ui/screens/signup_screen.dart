import 'package:eClassify/features/auth/cubits/email_registration_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_verification_cubit.dart';
import 'package:eClassify/features/auth/models/auth_request.dart';
import 'package:eClassify/features/auth/ui/widgets/auth_button.dart';
import 'package:eClassify/features/auth/ui/widgets/auth_switcher_text.dart';
import 'package:eClassify/features/auth/ui/widgets/email_phone_toggle.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/inputs/phone_input.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({
    required this.onChangeAuthType,
    required this.isBusy,
    required this.agreedToTerms,
    super.key,
  });

  final VoidCallback onChangeAuthType;
  final ValueNotifier<bool> isBusy;
  final ValueNotifier<bool> agreedToTerms;

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  late final ValueNotifier<bool> _isEmailLogin;

  final TextController _emailController = TextController();
  final PhoneInputController _phoneController = PhoneInputController();
  final TextController _passwordController = TextController();

  bool get isEmailLoginAvailable => Constant.systemSettings.isEmailAuthEnabled;

  bool get isPhoneLoginAvailable => Constant.systemSettings.isPhoneAuthEnabled;

  bool get isBusy => widget.isBusy.value;

  @override
  void initState() {
    super.initState();

    // Prioritize Phone login if available; otherwise default to Email login if available.
    final initialAuth = !isPhoneLoginAvailable && isEmailLoginAvailable;
    _isEmailLogin = ValueNotifier(initialAuth);

    _isEmailLogin.addListener(_clearControllers);
  }

  @override
  void dispose() {
    _isEmailLogin.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
  }

  void _registerUser() async {
    if (isBusy) return;
    if (Constant.requireTermsConsent && !widget.agreedToTerms.value) return;

    final isEmailLogin = _isEmailLogin.value;

    final hasValidEmailFields =
        isEmailLogin &&
        _emailController.validate() & _passwordController.validate();
    final hasValidPhoneFields =
        !isEmailLogin &&
        await _phoneController.validateAsync() & _passwordController.validate();

    if (hasValidEmailFields) {
      context.read<EmailRegistrationCubit>().signUp(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } else if (hasValidPhoneFields) {
      context.read<OtpVerificationCubit>().sendOtp(
        formattedNumber: _phoneController.formattedNumber,
        contact: _phoneController.contact,
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ValueListenableBuilder(
            valueListenable: _isEmailLogin,
            builder: (context, isEmailLogin, child) {
              final label = isEmailLogin
                  ? 'signUpWithEmail'
                  : 'signUpWithPhone';
              return Text(
                label.translate(context),
                style: context.bodyLarge.muted(context),
              );
            },
          ),
          24.vGap,
          ValueListenableBuilder(
            valueListenable: _isEmailLogin,
            builder: (context, isEmailLogin, child) {
              if (isEmailLogin) {
                return CustomTextField(
                  controller: _emailController,
                  validators: [EmptyFieldValidator(), EmailValidator()],
                  hintKey: 'emailAddress',
                  autoFillHints: const [AutofillHints.email],
                );
              } else {
                return PhoneInput(controller: _phoneController);
              }
            },
          ),
          12.vGap,
          CustomTextField(
            controller: _passwordController,
            validators: [EmptyFieldValidator()],
            obscureText: true,
            hintKey: 'password',
            autoFillHints: const [
              AutofillHints.password,
              AutofillHints.newPassword,
            ],
          ),
          16.vGap,
          if (Constant.requireTermsConsent)
            ValueListenableBuilder(
              valueListenable: widget.agreedToTerms,
              builder: (context, isAgreed, child) {
                return SignUpButton(
                  notifier: _isEmailLogin,
                  onPressed: _registerUser,
                  isEnabled: isAgreed,
                );
              },
            )
          else
            SignUpButton(notifier: _isEmailLogin, onPressed: _registerUser),
          if (isEmailLoginAvailable && isPhoneLoginAvailable) ...[
            16.vGap,
            EmailPhoneToggle(notifier: _isEmailLogin, isBusy: widget.isBusy),
          ],
          16.vGap,
          AuthSwitcherText(
            type: AuthType.signUp,
            onAuthChangeType: widget.onChangeAuthType,
          ),
        ],
      ),
    );
  }
}
