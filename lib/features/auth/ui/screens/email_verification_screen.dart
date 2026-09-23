import 'dart:async';
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/features/auth/cubits/email_registration_cubit.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider.value(
        value: routeSettings.arguments as EmailRegistrationCubit,
        child: const EmailVerificationScreen(),
      ),
    );
  }

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with WidgetsBindingObserver {
  // Cross-device verification (e.g. user clicks the link on their PC) has no
  // app-resume event to hook into, so poll silently as a fallback alongside
  // the lifecycle-based check below.
  static const _pollInterval = Duration(seconds: 5);
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkVerification());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkVerification();
    }
  }

  void _checkVerification() {
    if (!mounted) return;
    context.read<EmailRegistrationCubit>().checkEmailVerification();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Android's intent opens the Mail app itself (no compose sheet). iOS has
  // no equivalent — mailto: only opens compose — so the button that calls
  // this is Android-only (see build()).
  Future<void> _openMail() async {
    const AndroidIntent(
      action: 'android.intent.action.MAIN',
      category: 'android.intent.category.APP_EMAIL',
      flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
    ).launch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EmailRegistrationCubit, EmailRegistrationState>(
      listener: (context, state) {
        if (state is EmailRegistrationInProgress) {
          _pollTimer?.cancel();
          LoadingOverlay.show(context);
        }
        if (state is EmailRegistrationSuccess) {
          LoadingOverlay.hide();
          // Registration is done — stop reacting to app-resume and poll
          // events now, not just in dispose(). This screen can stay mounted
          // underneath whatever gets pushed next, and without this it keeps
          // calling checkEmailVerification() on every resume indefinitely.
          _pollTimer?.cancel();
          WidgetsBinding.instance.removeObserver(this);
          context.read<AuthSessionCubit>().completeSignUp(state.user);
        }
      },
      child: AppScaffold(
        body: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomImage(src: AppAssets.illustrators.verificationMail),
              24.vGap,
              Text(
                'emailVerificationTitle'.translate(context),
                style: context.headlineSmall.semiBold,
                textAlign: TextAlign.center,
              ),
              8.vGap,
              Text(
                'emailVerificationDescription'.translate(context),
                style: context.bodyMedium,
                textAlign: TextAlign.center,
              ),
              // iOS has no scheme to open Mail directly to the inbox —
              // mailto: only opens a compose sheet, so skip the shortcut
              // there and rely on the background poll instead.
              if (Platform.isAndroid) ...[
                24.vGap,
                AppButton(
                  variant: AppButtonVariant.filled,
                  onPressed: _openMail,
                  title: 'checkMail',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
