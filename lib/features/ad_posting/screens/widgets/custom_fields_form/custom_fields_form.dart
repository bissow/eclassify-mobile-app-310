import 'package:eClassify/features/custom_fields/cubits/custom_fields_cubit.dart';
import 'package:eClassify/features/ad_posting/cubits/ad_posting_cubit.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/features/custom_fields/models/custom_field.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/language_tab_bar.dart';
import 'package:eClassify/features/custom_fields/screens/custom_fields_controller.dart';
import 'package:eClassify/features/custom_fields/screens/custom_fields_factory.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomFieldsForm extends StatefulWidget {
  const CustomFieldsForm({super.key});

  @override
  State<CustomFieldsForm> createState() => _CustomFieldsFormState();
}

class _CustomFieldsFormState extends State<CustomFieldsForm> {
  /// Complete list of custom fields.
  late final List<CustomField> _originalFields;
  late final bool _hasTextField;
  final CustomFieldsController _controller = CustomFieldsController();

  late final ValueNotifier<Language> _languageNotifier;

  /// List of custom fields for the current language.
  late List<CustomField> _languageFilteredFields;

  @override
  void initState() {
    super.initState();
    _originalFields =
        (context.read<CustomFieldsCubit>().state as CustomFieldsSuccess).fields;
    _languageFilteredFields = List.from(_originalFields);
    _hasTextField = _originalFields.any((field) => field is TextInputField);

    // Initialize Language Notifier
    final languages = Constant.systemSettings.languages;
    final defaultLanguage = languages.firstWhere((l) => l.isDefault);
    _languageNotifier = ValueNotifier(defaultLanguage);

    _loadLanguageData(_languageNotifier.value);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AdPostingStepController.of(context).register(
      onPrevious: () {
        context.read<AdPostingCubit>().previousStep();
      },
      onNext: () {
        if (!_controller.validate()) {
          _controller.revealFirstError();
          return;
        }
        _updateCustomFieldsData();
        context.read<AdPostingCubit>().nextStep();
      },
    );
  }

  void _updateCustomFieldsData() {
    final values = {
      for (final element in _controller.data.values)
        element.field.id: ?element.value,
    };
    context.read<AdPostingCubit>().updateData(
      (data) => data.copyWith(
        customFieldsEntry: MapEntry(_languageNotifier.value.id, values),
      ),
    );
  }

  void _loadLanguageData(Language language) {
    final data = context.read<AdPostingCubit>().state.adPostingData;
    final values = data.customFields?[language.id];

    if (language.isDefault) {
      _languageFilteredFields = List.from(_originalFields);
    } else {
      _languageFilteredFields = List.from(_originalFields)
        ..removeWhere((field) => field is! TextInputField);
    }

    _controller
      ..clear()
      ..registerFields(
        _languageFilteredFields,
        initialValues: values,
        isDefaultLanguage: language.isDefault,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_hasTextField)
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
              vertical: 20,
            ),
            child: LanguageTabBar(
              onLanguageChanged: (language) async {
                if (_languageNotifier.value.isDefault &&
                    !_controller.validate()) {
                  _controller.revealFirstError();
                  return false;
                }
                _updateCustomFieldsData();
                _loadLanguageData(language);
                _languageNotifier.value = language;
                return true;
              },
            ),
          ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: _languageNotifier,
            builder: (context, language, child) {
              return SingleChildScrollView(
                padding: context.bodyPadding(),
                child: CustomFieldsControllerProvider(
                  controller: _controller,
                  isDefaultLanguage: language.isDefault,
                  child: Column(
                    spacing: 16,
                    children: [
                      for (final field in _languageFilteredFields)
                        CustomFieldsWidgetFactory.createField(field),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
