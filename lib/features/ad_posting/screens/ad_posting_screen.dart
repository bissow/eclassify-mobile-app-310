import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/network/api_error_helper.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/features/ad_posting/cubits/ad_posting_cubit.dart';
import 'package:eClassify/features/ad_posting/cubits/generate_description_cubit.dart';
import 'package:eClassify/features/ad_posting/cubits/generate_meta_cubit.dart';
import 'package:eClassify/features/ad_posting/models/ad_posting_step.dart';
import 'package:eClassify/features/ad_posting/repository/ai_repository.dart';
import 'package:eClassify/features/ad_posting/screens/modals/confirm_back_navigation_dialog.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ad_posting_form_buttons.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ad_posting_step_widget.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ad_type_selection/ad_type_selection_step.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/basic_details_form/basic_details_form.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/category_selection/category_breadcrumbs_view.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/category_selection/category_selection_step.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/custom_fields_form/custom_fields_form.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/location_selection_step/location_selection_step.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/media_selection/media_selection_step.dart';
import 'package:eClassify/features/category/cubits/category_browsing_cubit.dart';
import 'package:eClassify/features/custom_fields/cubits/custom_fields_cubit.dart';
import 'package:eClassify/features/item/cubits/manage_item_cubit.dart';
import 'package:eClassify/features/item/models/ad_posting_data.dart';
import 'package:eClassify/features/location/cubits/location_search_cubit.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdPostingScreen extends StatefulWidget {
  const AdPostingScreen({this.data, super.key});

  final AdPostingData? data;

  static Route route(RouteSettings settings) {
    final data = settings.arguments as AdPostingData?;
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => AdPostingCubit(data)),
          BlocProvider(
            create: (_) => CategoryBrowsingCubit(showLastCategory: true),
          ),
          BlocProvider(create: (_) => CustomFieldsCubit()),
          BlocProvider(create: (_) => GenerateMetaCubit()),
          BlocProvider(
            create: (_) => GenerateDescriptionCubit(AIRepository.instance),
          ),
          if (Constant.systemSettings.mapProvider.isPaidApi)
            BlocProvider(create: (_) => LocationSearchCubit()),
          BlocProvider(create: (_) => ManageItemCubit()),
        ],

        child: AdPostingScreen(data: data),
      ),
    );
  }

  @override
  State<AdPostingScreen> createState() => _AdPostingScreenState();
}

class _AdPostingScreenState extends State<AdPostingScreen> {
  final PageController _pageController = PageController();
  final AdPostingStepController _stepController = AdPostingStepController();

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      context.read<CustomFieldsCubit>().getCustomFields(
        categoryId: widget.data!.category!.id,
      );
    }
  }

  void _handleBackNavigation() async {
    final cubit = context.read<AdPostingCubit>();

    if (cubit.isEdit) {
      Navigator.of(context).pop();
      return;
    }

    final categoryCubit = context.read<CategoryBrowsingCubit>();

    if (categoryCubit.pathNotifier.isNotEmpty &&
        cubit.state.activeStep == AdPostingStep.category) {
      // Category picker handles back navigation at the category level.
      return;
    }

    switch (cubit.state.activeStep) {
      case AdPostingStep.category:
        cubit.previousStep();
        return;

      case AdPostingStep.adType:
        Navigator.of(context).pop();
        return;

      default:
        final confirmed =
            await ConfirmBackNavigationDialog.show(context) ?? false;

        if (confirmed) {
          Navigator.of(context).pop();
        }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: _AdPostingListenerScope(
        stepController: _stepController,
        controller: _pageController,
        child: AdPostingStepControllerProvider(
          controller: _stepController,
          child: BlocBuilder<AdPostingCubit, AdPostingState>(
            builder: (context, state) {
              final totalSteps = state.steps.length;
              return AppScaffold(
                appBar: AppBar(
                  title: Text('adDetails'.translate(context)),
                  leading: BackButton(onPressed: _handleBackNavigation),
                ),
                bottomNavigationBar: const AdPostingFormButtons(),
                body: Column(
                  children: [
                    AdPostingStepWidget(),
                    CategoryBreadcrumbsView(),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: totalSteps,
                        itemBuilder: (context, index) {
                          final step = state.steps[index];
                          return _AdPostingStepFactory.getStep(step);
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AdPostingStepFactory {
  static Widget getStep(AdPostingStep step) {
    return switch (step) {
      AdPostingStep.adType => const AdTypeSelectionStep(),
      AdPostingStep.category => const CategorySelectionStep(),
      AdPostingStep.baseDetails => const BasicDetailsForm(),
      AdPostingStep.customFields => const CustomFieldsForm(),
      AdPostingStep.mediaUpload => const MediaSelectionStep(),
      AdPostingStep.location => const LocationSelectionStep(),
    };
  }
}

class _AdPostingListenerScope extends StatelessWidget {
  const _AdPostingListenerScope({
    required this.stepController,
    required this.controller,
    required this.child,
  });

  final AdPostingStepController stepController;
  final PageController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AdPostingCubit, AdPostingState>(
          listenWhen: (previous, current) =>
              previous.activeStep != current.activeStep,
          listener: (context, state) {
            final index = state.steps.indexOf(state.activeStep);
            if (controller.hasClients && controller.page?.round() != index) {
              controller.jumpToPage(index);
            }
            stepController.clear();
          },
        ),
        BlocListener<CustomFieldsCubit, CustomFieldsState>(
          listener: (context, state) {
            if (state case final CustomFieldsSuccess s
                when s.fields.isNotEmpty) {
              context.read<AdPostingCubit>().addStep(
                AdPostingStep.customFields,
                after: AdPostingStep.baseDetails,
              );
            }
          },
        ),
        BlocListener<ManageItemCubit, ManageItemState>(
          listener: (context, state) {
            if (state is ManageItemLoading) {
              LoadingOverlay.show(context);
            }
            if (state is ManageItemSuccess) {
              LoadingOverlay.hide();
              final isEdit = context.read<AdPostingCubit>().isEdit;
              Navigator.of(context).pushNamed(
                Routes.adPostingSuccessScreen,
                arguments: {
                  'item': state.item,
                  'is_edited': isEdit,
                  'is_upload_in_progress': state.isUploadInProgress,
                },
              );
            }
            if (state is ManageItemFailure) {
              LoadingOverlay.hide();
              HelperUtils.showSnackBarMessage(
                context,
                ApiErrorHelper.errorMessageFromException(context, state.error),
              );
            }
          },
        ),
      ],
      child: child,
    );
  }
}
