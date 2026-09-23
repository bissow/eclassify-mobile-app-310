import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/verification/cubits/submit_verification_cubit.dart';
import 'package:eClassify/features/verification/cubits/verification_fields_cubit.dart';
import 'package:eClassify/features/verification/cubits/verification_request_cubit.dart';
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
            child:
                BlocConsumer<VerificationFieldsCubit, VerificationFieldsState>(
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
                            title: 'submit',
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
          ),
      ),
    );
  }
}
