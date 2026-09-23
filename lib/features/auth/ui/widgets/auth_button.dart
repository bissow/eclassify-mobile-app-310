import 'package:eClassify/features/auth/cubits/email_registration_cubit.dart';
import 'package:eClassify/features/auth/cubits/login_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/cubits/otp_verification_cubit.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _AuthActionButton extends StatelessWidget {
  const _AuthActionButton({
    required this.isLoading,
    required this.labelKey,
    required this.onPressed,
  });

  final bool isLoading;
  final String labelKey;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      variant: AppButtonVariant.filled,
      onPressed: onPressed,
      child: isLoading
          ? LoadingIndicator.inlineDots()
          : Text(labelKey.translate(context)),
    );
  }
}

class SignInButton extends StatelessWidget {
  const SignInButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final loginState = context.watch<LoginCubit>().state;
    final isLoading = switch (loginState) {
      LoginInProgress s
          when s.provider == AuthProvider.email ||
              s.provider == AuthProvider.phone =>
        true,
      _ => false,
    };
    return _AuthActionButton(
      isLoading: isLoading,
      labelKey: 'signIn',
      onPressed: onPressed,
    );
  }
}

class SignUpButton extends StatelessWidget {
  const SignUpButton({
    required this.notifier,
    required this.onPressed,
    this.isEnabled = true,
    super.key,
  });

  final ValueNotifier<bool> notifier;
  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final emailState = context.watch<EmailRegistrationCubit>().state;
    final otpState = context.watch<OtpVerificationCubit>().state;
    final isLoading =
        emailState is EmailRegistrationInProgress ||
        otpState is OtpFlowSending ||
        otpState is OtpFlowVerifying;

    return ValueListenableBuilder(
      valueListenable: notifier,
      builder: (context, isEmailLogin, child) {
        return _AuthActionButton(
          isLoading: isLoading,
          labelKey: isEmailLogin ? 'verifyEmailAddress' : 'sendOTP',
          onPressed: isEnabled ? onPressed : null,
        );
      },
    );
  }
}
