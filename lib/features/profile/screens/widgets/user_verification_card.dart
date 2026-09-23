import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_assets.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
import 'package:eClassify/features/verification/models/verification_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserVerificationCard extends StatefulWidget {
  const UserVerificationCard({super.key});

  @override
  State<UserVerificationCard> createState() => _UserVerificationCardState();
}

class _UserVerificationCardState extends State<UserVerificationCard> {
  @override
  void initState() {
    super.initState();
    context.read<VerificationRequestCubit>().fetchVerificationRequest();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VerificationRequestCubit, VerificationRequestState>(
      builder: (context, state) {
        if (state is VerificationRequestLoading) {
          return const SizedBox.shrink();
        }

        final request = state is VerificationRequestSuccess
            ? state.request
            : null;

        if (request?.status == VerificationRequestStatus.approved) {
          return const SizedBox.shrink();
        }

        final config = _VerificationCardUIResolver.resolve(context, request);

        return Card.outlined(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 10,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          if (config.leadingIcon != null)
                            Icon(config.leadingIcon, color: config.color),
                          Expanded(
                            child: Column(
                              spacing: 5,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  config.title.translate(context),
                                  style: context.labelLarge.bold,
                                ),
                                Text(
                                  config.subtitle.translate(context),
                                  style: context.bodySmall.muted(context),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (request?.status == VerificationRequestStatus.rejected)
                        const Divider(height: 1),
                      if (config.buttonTitle.isNotNullAndNotEmpty)
                        AppButton(
                          variant: AppButtonVariant.filled,
                          width: AppButtonWidth.content,
                          size: AppButtonSize.compact,
                          textStyle: context.labelMedium.bold,
                          onPressed: () {
                            if (request?.status ==
                                VerificationRequestStatus.initial) {
                              Navigator.of(
                                context,
                              ).pushNamed(Routes.verificationIntroduction);
                            } else {
                              Navigator.of(
                                context,
                              ).pushNamed(Routes.verification);
                            }
                          },
                          title: config.buttonTitle!,
                        ),
                    ],
                  ),
                ),
                if (config.trailingIcon.isNotNullAndNotEmpty)
                  CustomImage(
                    src: config.trailingIcon,
                    size: const Size(136, 80),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VerificationCardUIResolver {
  static _VerificationCardUIConfig resolve(
    BuildContext context,
    VerificationRequest? request,
  ) {
    final status = request?.status;
    return switch (status) {
      VerificationRequestStatus.pending => _VerificationCardUIConfig(
        leadingIcon: AppIcons.sealQuestion,
        color: Colors.amber,
        title: 'verificationInReviewTitle',
        subtitle: 'verificationInReviewSubtitle',
        buttonTitle: 'checkVerificationStatus',
      ),
      VerificationRequestStatus.rejected => _VerificationCardUIConfig(
        leadingIcon: AppIcons.sealWarning,
        title: 'verificationRejectedTitle',
        subtitle:
            '${'rejectionReason'.translate(context)}: '
            '${request?.rejectionReason ?? 'N/A'}',
        buttonTitle: 'resubmitVerification',
        color: Colors.red,
      ),
      _ => _VerificationCardUIConfig(
        title: 'verificationInitialTitle',
        subtitle: 'verificationInitialSubtitle',
        buttonTitle: 'getStarted',
        trailingIcon: AppAssets.illustrators.userVerification,
      ),
    };
  }
}

class _VerificationCardUIConfig {
  _VerificationCardUIConfig({
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.trailingIcon,
    this.color,
    this.buttonTitle,
  });

  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final String? trailingIcon;
  final Color? color;
  final String? buttonTitle;
}
