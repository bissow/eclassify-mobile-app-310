import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/features/auth/cubits/email_password_reset_cubit.dart';
import 'package:eClassify/features/auth/cubits/email_registration_cubit.dart';
import 'package:eClassify/features/auth/cubits/login_cubit.dart';
import 'package:eClassify/features/auth/cubits/otp_verification_cubit.dart';
import 'package:eClassify/features/auth/cubits/phone_password_reset_cubit.dart';
import 'package:eClassify/features/auth/models/auth_request.dart';
import 'package:eClassify/features/auth/ui/listeners/auth_listeners_scope.dart';
import 'package:eClassify/features/auth/ui/screens/signin_screen.dart';
import 'package:eClassify/features/auth/ui/screens/signup_screen.dart';
import 'package:eClassify/features/auth/ui/widgets/terms_and_conditions_widget.dart';
import 'package:eClassify/core/widgets/inputs/skip_button_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => LoginCubit()),
          BlocProvider(create: (_) => EmailRegistrationCubit()),
          BlocProvider(create: (_) => OtpVerificationCubit()),
          BlocProvider(create: (_) => EmailPasswordResetCubit()),
          BlocProvider(create: (_) => PhonePasswordResetCubit()),
        ],
        child: AuthScreen(),
      ),
    );
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final ValueNotifier<AuthType> _authModeNotifier = ValueNotifier(
    AuthType.signIn,
  );
  final ValueNotifier<bool> _isBusy = ValueNotifier(false);
  final ValueNotifier<bool> _agreedToTerms = ValueNotifier(false);

  @override
  void dispose() {
    _authModeNotifier.dispose();
    _isBusy.dispose();
    _agreedToTerms.dispose();
    super.dispose();
  }

  void _changeAuthMode(AuthType mode) {
    if (_isBusy.value) return;
    _agreedToTerms.value = false;
    _authModeNotifier.value = mode;
  }

  @override
  Widget build(BuildContext context) {
    return AuthListenersScope(
      isBusyNotifier: _isBusy,
      child: AppScaffold(
        appBar: AppBar(
          backgroundColor: context.colorScheme.surface,
          automaticallyImplyLeading: false,
          actions: [
            SkipButtonWidget(
              onTap: () {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(Routes.main, (route) => false);
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: context.bodyPadding(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'welcomeMessage'.translate(context, {
                  'application_name': AppConfig.applicationName,
                }),
                style: context.headlineSmall,
              ),
              8.vGap,
              ValueListenableBuilder(
                valueListenable: _authModeNotifier,
                builder: (context, mode, child) {
                  return switch (mode) {
                    AuthType.signIn => SignInScreen(
                      onChangeAuthType: () => _changeAuthMode(AuthType.signUp),
                      isBusy: _isBusy,
                    ),
                    AuthType.signUp => SignupScreen(
                      onChangeAuthType: () => _changeAuthMode(AuthType.signIn),
                      isBusy: _isBusy,
                      agreedToTerms: _agreedToTerms,
                    ),
                  };
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: _authModeNotifier,
          builder: (context, mode, child) {
            return switch (mode) {
              AuthType.signIn => const TermsAndConditionsWidget(),
              AuthType.signUp when !Constant.requireTermsConsent =>
                const TermsAndConditionsWidget(),
              AuthType.signUp => ValueListenableBuilder(
                valueListenable: _agreedToTerms,
                builder: (context, isChecked, child) {
                  return TermsAndConditionsWidget(
                    showCheckbox: true,
                    isChecked: isChecked,
                    onCheckboxChanged: (val) =>
                        _agreedToTerms.value = val ?? false,
                  );
                },
              ),
            };
          },
        ),
      ),
    );
  }
}
