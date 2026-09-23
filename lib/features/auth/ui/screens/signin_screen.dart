import 'dart:io';

import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/inputs/phone_input.dart';
import 'package:eClassify/features/auth/cubits/login_cubit.dart';
import 'package:eClassify/features/auth/models/auth_request.dart';
import 'package:eClassify/features/auth/ui/modals/forgot_password_bottom_sheet.dart';
import 'package:eClassify/features/auth/ui/widgets/auth_button.dart';
import 'package:eClassify/features/auth/ui/widgets/auth_provider_button.dart';
import 'package:eClassify/features/auth/ui/widgets/auth_switcher_text.dart';
import 'package:eClassify/features/auth/ui/widgets/email_phone_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({
    required this.onChangeAuthType,
    required this.isBusy,
    super.key,
  });

  final VoidCallback onChangeAuthType;
  final ValueNotifier<bool> isBusy;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  late final ValueNotifier<bool> _isEmailLogin;

  final TextController _emailController = TextController();
  final PhoneInputController _phoneController = PhoneInputController();
  final TextController _passwordController = TextController();

  bool get isEmailLoginAvailable => Constant.systemSettings.isEmailAuthEnabled;

  bool get isPhoneLoginAvailable => Constant.systemSettings.isPhoneAuthEnabled;

  bool get isGoogleLoginAvailable =>
      Constant.systemSettings.isGoogleAuthEnabled;

  bool get isAppleLoginAvailable => Constant.systemSettings.isAppleAuthEnabled;

  bool get isBusy => widget.isBusy.value;

  bool get isEitherEmailOrPhoneAvailable =>
      isEmailLoginAvailable || isPhoneLoginAvailable;

  bool get hasMoreThanOneMethods =>
      [
        isEmailLoginAvailable,
        isPhoneLoginAvailable,
        isGoogleLoginAvailable,
        isAppleLoginAvailable,
      ].where((e) => e).length >
      1;

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

  void _onSignIn() async {
    if (isBusy) return;

    final isEmailLogin = _isEmailLogin.value;
    final hasValidEmailFields =
        isEmailLogin &&
        _emailController.validate() & _passwordController.validate();
    final hasValidPhoneFields =
        !isEmailLogin &&
        await _phoneController.validateAsync() & _passwordController.validate();

    if (hasValidEmailFields) {
      context.read<LoginCubit>().login(
        EmailAuthRequest(
          authType: AuthType.signIn,
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );
    } else if (hasValidPhoneFields) {
      context.read<LoginCubit>().login(
        PhoneAuthRequest(
          contact: _phoneController.contact,
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isEitherEmailOrPhoneAvailable) ...[
            ValueListenableBuilder(
              valueListenable: _isEmailLogin,
              builder: (context, isEmailLogin, child) {
                final label = isEmailLogin
                    ? 'signInWithEmail'
                    : 'signInWithPhone';
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
              autoFillHints: const [AutofillHints.password],
            ),
            4.vGap,
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AppButton(
                variant: AppButtonVariant.text,
                width: AppButtonWidth.content,
                size: AppButtonSize.compact,
                foregroundColor: context.colorScheme.onSurface,
                onPressed: () async {
                  if (isBusy) return;
                  if (!_isEmailLogin.value &&
                      !await _phoneController.validateAsync())
                    return;
                  ForgotPasswordBottomSheet.show(
                    context,
                    isForEmail: _isEmailLogin.value,
                    email: _emailController.text,
                    contact: _phoneController.contact,
                  );
                },
                child: Text(
                  'forgotPassword'.translate(context),
                  style: context.bodySmall,
                ),
              ),
            ),
            16.vGap,
            SignInButton(onPressed: _onSignIn),
          ],
          if (isEitherEmailOrPhoneAvailable) ...[
            16.vGap,
            AuthSwitcherText(
              type: AuthType.signIn,
              onAuthChangeType: widget.onChangeAuthType,
            ),
          ],
          if (hasMoreThanOneMethods && isEitherEmailOrPhoneAvailable) ...[
            16.vGap,
            Text(
              'orSignInWith'.translate(context),
              style: context.labelMedium.muted(context),
              textAlign: TextAlign.center,
            ),
          ],
          16.vGap,
          if (isGoogleLoginAvailable)
            AuthProviderButton.google(
              onPressed: () {
                if (!isBusy) {
                  // isBusy toggle is handled by AuthListenersScope
                  context.read<LoginCubit>().login(GoogleAuthRequest());
                }
              },
            ),
          if (isAppleLoginAvailable && Platform.isIOS) ...[
            12.vGap,
            AuthProviderButton.apple(
              onPressed: () {
                if (!isBusy) {
                  // isBusy toggle is handled by AuthListenersScope
                  context.read<LoginCubit>().login(AppleAuthRequest());
                }
              },
            ),
          ],
          12.vGap,
          if (isPhoneLoginAvailable && isEmailLoginAvailable)
            EmailPhoneToggle(notifier: _isEmailLogin, isBusy: widget.isBusy),
        ],
      ),
    );
  }
}
