import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
import 'package:eClassify/features/verification/models/verification_request.dart';
import 'package:eClassify/features/profile/screens/widgets/follow_users_count_widget.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/text/auto_size_text.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto updated as the parent screen watches AuthSessionCubit
    final isAuthenticated = AppSession.isAuthenticated;

    return Card.filled(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 12,
          children: [
            _ProfileDetails(isAuthenticated: isAuthenticated),
            if (isAuthenticated) ...[
              const Divider(height: 1),
              FollowUsersCountWidget(),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  Widget build(BuildContext context) {
    final user = AppSession.currentUser;
    final config = switch (isAuthenticated) {
      true => (title: user!.name, subtitle: user.email),
      false => (
        title: 'guestUser'.translate(context),
        subtitle: 'loginFirst'.translate(context),
      ),
    };

    return Row(
      spacing: 10,
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: context.colorScheme.surface,
          child: CustomImage(
            src: user?.profile,
            size: Size.square(64),
            radius: 32,
            errorImage: UserPlaceholderImage(
              placeholder: user?.placeholder,
              size: Size.square(64),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (config.title.isNotNullAndNotEmpty)
                Row(
                  spacing: 2,
                  children: [
                    Text(config.title, style: context.labelLarge.bold),
                    if (AppSession.isAuthenticated) const _VerifiedIcon(),
                  ],
                ),
              if (config.subtitle.isNotNullAndNotEmpty)
                Text(config.subtitle, style: context.bodyMedium),
            ],
          ),
        ),
        if (!isAuthenticated)
          AppButton(
            variant: AppButtonVariant.outlined,
            width: AppButtonWidth.content,
            size: AppButtonSize.compact,
            style: ButtonStyle(
              minimumSize: const WidgetStatePropertyAll(Size(100, 32)),
              maximumSize: const WidgetStatePropertyAll(Size(150, 32)),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.auth);
            },
            child: AutoSizeText(
              text: 'login'.translate(context),
              maxLines: 1,
              style: context.labelLarge.primary(context),
              textAlign: TextAlign.center,
              minimumFontSize: 8,
            ),
          )
        else
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: context.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.userProfile);
            },
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(AppIcons.pencilSimpleLine),
            ),
          ),
      ],
    );
  }
}

class _VerifiedIcon extends StatelessWidget {
  const _VerifiedIcon();

  @override
  Widget build(BuildContext context) {
    final user = AppSession.currentUser;
    final isVerified = context.select<VerificationRequestCubit, bool>(
      (cubit) => switch (cubit.state) {
        final VerificationRequestSuccess s
            when s.request.status == VerificationRequestStatus.approved =>
          true,
        _ => user?.isVerified ?? false,
      },
    );
    if (isVerified) {
      return Icon(
        AppIcons.sealCheckFill,
        size: 16,
        color: context.colorScheme.tertiary,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
