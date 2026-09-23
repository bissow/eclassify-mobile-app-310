import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/auth/cubits/otp_flow_state.dart';
import 'package:eClassify/features/auth/cubits/phone_password_reset_cubit.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SetNewPasswordScreen extends StatefulWidget {
  const SetNewPasswordScreen({super.key});

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider.value(
        value: routeSettings.arguments as PhonePasswordResetCubit,
        child: const SetNewPasswordScreen(),
      ),
    );
  }
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _newPasswordController = TextController();
  final _confirmPasswordController = TextController();

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (context.read<PhonePasswordResetCubit>().state
        is PhoneResetSettingPassword) {
      return;
    }
    final hasValidFields =
        _newPasswordController.validate() &
        _confirmPasswordController.validate();
    if (!hasValidFields) return;

    context.read<PhonePasswordResetCubit>().resetPassword(
      newPassword: _newPasswordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PhonePasswordResetCubit, OtpFlowState>(
      listener: (context, state) {
        if (state case PhoneResetSuccess()) {
          HelperUtils.showSnackBarMessage(
            context,
            'passwordResetSuccessfully'.translate(context),
          );
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(Routes.auth, (route) => false);
        }
        if (state case PhoneResetFailure(:final error)) {
          HelperUtils.showSnackBarMessage(
            context,
            ApiErrorHelper.errorMessageFromException(context, error),
          );
        }
      },
      child: AppScaffold(
        bottomAction: AppButton(
          variant: AppButtonVariant.filled,
          onPressed: _submit,
          child: BlocBuilder<PhonePasswordResetCubit, OtpFlowState>(
            builder: (context, state) {
              final isLoading = state is PhoneResetSettingPassword;
              return isLoading
                  ? LoadingIndicator.inlineDots()
                  : Text('resetPassword'.translate(context));
            },
          ),
        ),
        body: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              (kToolbarHeight * 2).vGap,
              Text(
                'resetPassword'.translate(context),
                style: context.headlineSmall.semiBold,
              ),
              8.vGap,
              Text(
                'createNewPasswordForYourAccount'.translate(context),
                style: context.bodyMedium.muted(context),
              ),
              24.vGap,
              CustomTextField(
                controller: _newPasswordController,
                validators: [
                  EmptyFieldValidator(),
                  TextLengthValidator(
                    min: 6,
                    max: null,
                    errorText: 'passwordWarning',
                  ),
                ],
                obscureText: true,
                hintKey: 'newPassword',
              ),
              12.vGap,
              CustomTextField(
                controller: _confirmPasswordController,
                validators: [
                  EmptyFieldValidator(),
                  CallbackValidator<String?>(
                    predicate: (value) => value == _newPasswordController.text,
                    errorText: 'passwordsDoNotMatch',
                  ),
                ],
                obscureText: true,
                hintKey: 'confirmPassword',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
