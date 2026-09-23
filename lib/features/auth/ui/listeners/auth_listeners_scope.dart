import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/features/auth/cubits/email_registration_cubit.dart';
import 'package:eClassify/features/auth/cubits/login_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/cubits/otp_verification_cubit.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/features/auth/ui/modals/email_not_verified_dialog.dart';
import 'package:eClassify/features/auth/ui/widgets/terms_acceptance_dialog.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthListenersScope extends StatelessWidget {
  const AuthListenersScope({
    required this.isBusyNotifier,
    required this.child,
    super.key,
  });

  final ValueNotifier<bool> isBusyNotifier;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listener: (context, state) async {
            if (state is ProfileSetupPending) {
              // Tear down everything above AuthScreen (e.g.
              // EmailVerificationScreen, still polling/observing lifecycle
              // resumes) before pushing — otherwise it stays alive
              // underneath and can re-trigger this same branch later,
              // stacking a second, blank profile screen. Stop at AuthScreen
              // specifically, not route.isFirst: this listener lives inside
              // AuthScreen itself, so removing it here would tear down the
              // very BlocListener running this callback mid-await.
              final user =
                  await Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.userProfile,
                        (route) => route.settings.name == Routes.auth,
                        arguments: state.user,
                      )
                      as User?;
              if (user != null) {
                // updateSession emits Authenticated, which this same
                // listener reacts to below — that's the sole redirect path.
                context.read<AuthSessionCubit>().updateSession(user);
              } else {
                context.read<AuthSessionCubit>().clearSession();
              }
            } else if (state is Authenticated) {
              TextInput.finishAutofillContext();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(Routes.main, (route) => false);
            }
          },
        ),
        BlocListener<LoginCubit, LoginState>(
          listener: (context, state) async {
            if (state is LoginInProgress) {
              isBusyNotifier.value = true;
            } else {
              isBusyNotifier.value = false;
            }
            if (state is LoginFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                ApiErrorHelper.errorMessageFromException(context, state.error),
              );
            }
            if (state is LoginSuccess) {
              context.read<AuthSessionCubit>().updateSession(state.user);
            }
            if (state is LoginEmailUnverified) {
              final shouldResend = await EmailNotVerifiedDialog.show(context);
              if (shouldResend == true && context.mounted) {
                await context.read<LoginCubit>().resendVerificationEmail();
                if (context.mounted) {
                  HelperUtils.showSnackBarMessage(
                    context,
                    'verificationEmailSent'.translate(context),
                  );
                }
              }
            }
            if (state is LoginRequiresTermsAcceptance) {
              final accepted = await TermsAcceptanceDialog.show(context);
              if (!context.mounted) return;
              if (accepted == true) {
                context.read<LoginCubit>().continueAfterTermsAccepted();
              } else {
                context.read<LoginCubit>().abortTermsAcceptance();
              }
            }
          },
        ),
        BlocListener<EmailRegistrationCubit, EmailRegistrationState>(
          listener: (context, state) {
            if (state is EmailRegistrationInProgress) {
              isBusyNotifier.value = true;
            } else {
              isBusyNotifier.value = false;
            }

            if (state is EmailVerificationSent) {
              Navigator.of(context).pushNamed(
                Routes.emailVerification,
                arguments: context.read<EmailRegistrationCubit>(),
              );
            }
            if (state is EmailRegistrationFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                ApiErrorHelper.errorMessageFromException(context, state.error),
              );
            }
          },
        ),
        BlocListener<OtpVerificationCubit, OtpFlowState>(
          listener: (context, state) {
            if (state is OtpFlowSending) {
              isBusyNotifier.value = true;
            } else {
              isBusyNotifier.value = false;
            }
            if (state is OtpFlowSent) {
              Navigator.of(context).pushNamed(
                Routes.otpVerification,
                arguments: context.read<OtpVerificationCubit>(),
              );
            }
            if (state is OtpVerificationFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                ApiErrorHelper.errorMessageFromException(context, state.error),
              );
            }
          },
        ),
      ],
      child: child,
    );
  }
}
