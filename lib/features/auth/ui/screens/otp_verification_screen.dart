import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/features/auth/cubits/base_otp_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/cubits/otp_verification_cubit.dart';
import 'package:eClassify/features/auth/cubits/phone_password_reset_cubit.dart';
import 'package:eClassify/features/auth/helpers/smart_auth_sms_retriever.dart';
import 'package:eClassify/features/auth/ui/widgets/otp_resend_timer.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

/// Shared by two flows — signup phone verification (OtpVerificationCubit)
/// and phone password reset (PhonePasswordResetCubit) — since both are
/// BaseOtpCubit underneath and only differ in what happens
/// once a token has been obtained. `OtpVerificationFailure` is deliberately
/// NOT handled here: it's shown globally by AuthListenersScope, which also
/// has to cover the initial sendOtp() call made from SignupScreen before
/// this screen is even pushed, so it stays global rather than split.
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider<BaseOtpCubit>.value(
        value: routeSettings.arguments as BaseOtpCubit,
        child: const OtpVerificationScreen(),
      ),
    );
  }
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String? _verificationId;

  @override
  void initState() {
    super.initState();
    _extractVerificationId(context.read<BaseOtpCubit>().state);
  }

  void _extractVerificationId(OtpFlowState state) {
    if (state case OtpFlowSent(:final verificationId)) {
      _verificationId = verificationId;
    }
  }

  void _verify(String code) {
    if (_verificationId != null) {
      context.read<BaseOtpCubit>().verifyOtp(
        verificationId: _verificationId!,
        smsCode: code,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BaseOtpCubit, OtpFlowState>(
      listener: (context, state) {
        _extractVerificationId(state);
        if (state case OtpVerificationSuccess(:final user)) {
          context.read<AuthSessionCubit>().completeSignUp(user);
        } else if (state case PhoneResetOtpVerified()) {
          Navigator.of(context).pushNamed(
            Routes.setNewPassword,
            arguments: context.read<BaseOtpCubit>() as PhonePasswordResetCubit,
          );
        } else if (state case PhoneResetOtpFailure(:final error)) {
          HelperUtils.showSnackBarMessage(
            context,
            ApiErrorHelper.errorMessageFromException(context, error),
          );
        }
      },
      child: BlocBuilder<BaseOtpCubit, OtpFlowState>(
        builder: (context, state) {
          final cubit = context.read<BaseOtpCubit>();
          return _OtpEntryView(
            phoneNumber: cubit.formattedNumber,
            isVerifying: state is OtpFlowVerifying,
            onVerify: _verify,
            onResend: cubit.resendOtp,
          );
        },
      ),
    );
  }
}

class _OtpEntryView extends StatefulWidget {
  const _OtpEntryView({
    required this.phoneNumber,
    required this.isVerifying,
    required this.onVerify,
    required this.onResend,
  });

  final String phoneNumber;
  final bool isVerifying;
  final ValueChanged<String> onVerify;
  final VoidCallback onResend;

  @override
  State<_OtpEntryView> createState() => _OtpEntryViewState();
}

class _OtpEntryViewState extends State<_OtpEntryView> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomAction: AppButton(
        variant: AppButtonVariant.filled,
        onPressed: () => widget.onVerify(_controller.text),
        child: widget.isVerifying
            ? LoadingIndicator.inlineDots()
            : Text('verify'.translate(context)),
      ),
      body: Padding(
        padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            (kToolbarHeight * 2).vGap,
            AspectRatio(
              aspectRatio: 2,
              child: CustomImage(
                src: AppAssets.illustrators.otpVerification,
                fit: BoxFit.contain,
              ),
            ),
            24.vGap,
            Text(
              'otpVerification'.translate(context),
              style: context.headlineSmall.semiBold,
            ),
            8.vGap,
            Text(
              'enterOTPSentToNumber'.translate(context, {
                'number': widget.phoneNumber,
              }),
              style: context.bodyMedium.muted(context),
            ),
            16.vGap,
            ClipRect(
              clipBehavior: Clip.hardEdge,
              child: Pinput(
                controller: _controller,
                length: 6,
                smsRetriever: SmartAuthSMSRetriever(),
                pinAnimationType: PinAnimationType.slide,
                slideTransitionBeginOffset: Offset(0, -.5),
                showCursor: true,
                cursor: VerticalDivider(
                  color: context.colorScheme.primary,
                  thickness: 2,
                  indent: 18,
                  endIndent: 18,
                ),
                onTapOutside: (_) {
                  FocusScope.of(context).unfocus();
                },
                onSubmitted: widget.onVerify,
                onCompleted: widget.onVerify,
                defaultPinTheme: PinTheme(
                  width: 60,
                  height: 60,
                  textStyle: context.titleMedium,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(),
                  ),
                ),
                focusedPinTheme: PinTheme(
                  width: 60,
                  height: 60,
                  textStyle: context.titleMedium,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colorScheme.primary),
                  ),
                ),
              ),
            ),
            12.vGap,
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OtpResendTimer(onResend: widget.onResend),
            ),
          ],
        ),
      ),
    );
  }
}
