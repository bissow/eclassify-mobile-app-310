import 'package:eClassify/features/auth/models/auth_request.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthSwitcherText extends StatelessWidget {
  const AuthSwitcherText({
    required this.type,
    required this.onAuthChangeType,
    super.key,
  });

  final AuthType type;
  final VoidCallback onAuthChangeType;

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      AuthType.signIn => 'dontHaveAnAccount',
      AuthType.signUp => 'alreadyHaveAnAccount',
    };

    final buttonLabel = switch (type) {
      AuthType.signIn => 'signUp',
      AuthType.signUp => 'signIn',
    };

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: label.translate(context), style: context.bodyMedium),
          const TextSpan(text: '\t'),
          TextSpan(
            text: buttonLabel.translate(context),
            style: context.bodyMedium.copyWith(
              color: context.colorScheme.primary,
              decorationColor: context.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = onAuthChangeType,
          ),
        ],
      ),
    );
  }
}
