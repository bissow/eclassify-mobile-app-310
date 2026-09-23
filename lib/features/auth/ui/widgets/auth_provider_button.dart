import 'package:eClassify/features/auth/cubits/login_cubit.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthProviderButton extends StatelessWidget {
  const AuthProviderButton._({
    required this.icon,
    required this.label,
    required this.provider,
    required this.onPressed,
  });

  factory AuthProviderButton.google({required VoidCallback onPressed}) {
    return AuthProviderButton._(
      icon: AppAssets.social.google,
      label: 'continueWithGoogle',
      provider: AuthProvider.google,
      onPressed: onPressed,
    );
  }

  factory AuthProviderButton.apple({required VoidCallback onPressed}) {
    return AuthProviderButton._(
      icon: AppAssets.social.apple,
      label: 'continueWithApple',
      provider: AuthProvider.apple,
      onPressed: onPressed,
    );
  }

  final String icon;
  final String label;
  final AuthProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prev, curr) => curr.provider == provider,
      builder: (context, state) {
        final isLoading = state is LoginInProgress;
        return AppButton(
          variant: AppButtonVariant.filled,
          backgroundColor: context.colorScheme.secondary,
          foregroundColor: context.colorScheme.onSecondary,
          icon: isLoading
              ? const SizedBox.shrink()
              : CustomImage(src: icon, size: Size.square(24)),
          child: isLoading
              ? LoadingIndicator.inlineDots(color: context.colorScheme.primary)
              : Text(label.translate(context)),
          onPressed: onPressed,
        );
      },
    );
  }
}
