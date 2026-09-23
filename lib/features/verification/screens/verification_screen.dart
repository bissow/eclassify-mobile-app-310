import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/features/verification/cubits/submit_verification_cubit.dart';
import 'package:eClassify/features/verification/cubits/verification_fields_cubit.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
import 'package:eClassify/features/verification/models/verification_request.dart';
import 'package:eClassify/features/custom_fields/screens/custom_fields_controller.dart';
import 'package:eClassify/features/custom_fields/screens/custom_fields_factory.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => VerificationFieldsCubit()),
          BlocProvider(create: (_) => SubmitVerificationCubit()),
        ],
        child: const VerificationScreen(),
      ),
    );
  }
}

class _VerificationScreenState extends State<VerificationScreen> {
  final CustomFieldsController _controller = CustomFieldsController();

  @override
  void initState() {
    super.initState();
    context.read<VerificationFieldsCubit>().getUserVerificationFields();
    context.read<VerificationRequestCubit>().fetchVerificationRequest();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubmitVerificationCubit, SubmitVerificationState>(
      listener: (context, state) {
        if (state is SubmitVerificationLoading) {
          LoadingOverlay.show(context);
        }
        if (state is SubmitVerificationSuccess) {
          LoadingOverlay.hide();
          context.read<VerificationRequestCubit>().fetchVerificationRequest();
          Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.verificationComplete,
            (route) => route.isFirst,
          );
        }
        if (state is SubmitVerificationFailure) {
          LoadingOverlay.hide();
        }
      },
      child: AppScaffold(
        appBar: AppBar(title: Text('userVerification'.translate(context))),
        body: Padding(
          padding: context.bodyPadding(),
          child: BlocBuilder<VerificationRequestCubit, VerificationRequestState>(
            builder: (context, requestState) {
              final request = requestState is VerificationRequestSuccess
                  ? requestState.request
                  : null;
              final isVerified = (AppSession.currentUser?.isVerified ?? false) ||
                  request?.status == VerificationRequestStatus.approved;
              final isUnderReview = !isVerified &&
                  (request?.status == VerificationRequestStatus.pending ||
                      request?.status == VerificationRequestStatus.resubmitted);

              if (requestState is VerificationRequestLoading && !isVerified) {
                return const Center(child: LoadingIndicator());
              }

              if (isVerified) {
                return _buildVerifiedView(context);
              }

              if (isUnderReview) {
                return _buildUnderReviewView(context, request);
              }

              return BlocConsumer<VerificationFieldsCubit, VerificationFieldsState>(
                  listener: (context, state) {
                    if (state case VerificationFieldsSuccess s) {
                      if (s.fields.isNotEmpty) {
                        _controller.registerFields(s.fields);
                      }
                    }
                  },
                  builder: (context, state) {
                    if (state is VerificationFieldsLoading) {
                      return Center(child: LoadingIndicator());
                    }
                    if (state is VerificationFieldsFailure) {
                      return QErrorWidget(
                        error: state.error,
                        onRetry: () {
                          context
                              .read<VerificationFieldsCubit>()
                              .getUserVerificationFields();
                        },
                      );
                    }
                    if (state is VerificationFieldsSuccess) {
                      if (state.fields.isEmpty) {
                        return QErrorWidget.emptyData(
                          onRetry: () {
                            context
                                .read<VerificationFieldsCubit>()
                                .getUserVerificationFields();
                          },
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (request?.status == VerificationRequestStatus.rejected) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'verificationRejectedTitle'.translate(context),
                                          style: context.labelMedium.bold.copyWith(color: Colors.red),
                                        ),
                                        if (request?.rejectionReason != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            '${'rejectionReason'.translate(context)}: ${request!.rejectionReason}',
                                            style: context.labelSmall,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          Text(
                            'verificationFormTitle'.translate(context),
                            style: context.titleMedium.semiBold,
                          ),
                          Text(
                            'verificationFormDescription'.translate(context),
                            style: context.bodyMedium.withColor(
                              context.mutedColor,
                            ),
                          ),
                          24.vGap,
                          Expanded(
                            child: SingleChildScrollView(
                              child: CustomFieldsControllerProvider(
                                controller: _controller,
                                child: Column(
                                  spacing: 4,
                                  children: [
                                    for (final field in state.fields)
                                      CustomFieldsWidgetFactory.createField(
                                        field,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          AppButton(
                            variant: AppButtonVariant.filled,
                            onPressed: () {
                              if (!_controller.validate()) return;
                              final data = _controller.data;
                              context.read<SubmitVerificationCubit>().submit(
                                data: data,
                              );
                            },
                            title: request?.status == VerificationRequestStatus.rejected
                                ? 'resubmitVerification'.translate(context)
                                : 'submit'.translate(context),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                );
              },
            ),
          ),
      ),
    );
  }

  Widget _buildVerifiedView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.shieldCheck,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.shieldCheck, size: 14, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    'verified'.translate(context),
                    style: context.labelMedium.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'accountVerified'.translate(context),
              style: context.titleLarge.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'verifiedAccountDescription'.translate(context),
              style: context.bodyMedium.withColor(context.mutedColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.colorScheme.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(AppIcons.lock, size: 20, color: context.mutedColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'verifiedCannotBeModified'.translate(context),
                      style: context.labelMedium.withColor(context.mutedColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              variant: AppButtonVariant.filled,
              title: 'backToProfile'.translate(context),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnderReviewView(
    BuildContext context,
    VerificationRequest? request,
  ) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                AppIcons.sealQuestion,
                size: 48,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AppIcons.sealQuestion, size: 14, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    'underReview'.translate(context),
                    style: context.labelMedium.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'verificationUnderReviewTitle'.translate(context),
              style: context.titleLarge.bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'userVerificationReviewDescription'.translate(context),
              style: context.bodyMedium.withColor(context.mutedColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.amber),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'verificationReviewPendingNotice'.translate(context),
                      style: context.labelMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              variant: AppButtonVariant.filled,
              title: 'backToProfile'.translate(context),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
