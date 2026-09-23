import 'package:eClassify/features/ad_posting/cubits/generate_description_cubit.dart';
import 'package:eClassify/features/ad_posting/cubits/generate_meta_cubit.dart';
import 'package:eClassify/core/cubits/currencies_cubit.dart';
import 'package:eClassify/features/custom_fields/cubits/custom_fields_cubit.dart';
import 'package:eClassify/features/ad_posting/cubits/ad_posting_cubit.dart';
import 'package:eClassify/features/category/models/category.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/extensions/currency_extension.dart';
import 'package:eClassify/core/models/currency.dart';
import 'package:eClassify/features/item/models/ad_posting_data.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ad_posting_step_controller.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/ai_generate_button.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/basic_details_form/seo_details_widget.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/currency_prefix_widget.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/field_skeleton.dart';
import 'package:eClassify/features/ad_posting/screens/widgets/language_tab_bar.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/inputs/phone_input.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/formatters/slug_formatter.dart';
import 'package:eClassify/core/utils/formatters/currency_formatter.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BasicDetailsForm extends StatefulWidget {
  const BasicDetailsForm({super.key});

  @override
  State<BasicDetailsForm> createState() => _BasicDetailsFormState();
}

class _BasicDetailsFormState extends State<BasicDetailsForm> {
  late final TextController _titleController;
  late final TextController _descriptionController;
  late final PhoneInputController _phoneController;
  late final TextController? _priceController;
  late final TextController? _minSalaryController;
  late final TextController? _maxSalaryController;
  late final TextController _adSlugController;
  late final SEODetailsController _seoController;

  late final Category _category;
  late final ValueNotifier<Currency> _currencyNotifier;
  late final ValueNotifier<Language> _languageNotifier;

  /// Currency the amount fields' text is currently formatted in. Input
  /// formatters only run on edits, so when the currency picker changes we
  /// re-format existing text from this currency's separators to the new one.
  late Currency _formattedCurrency;

  @override
  void initState() {
    super.initState();
    _category = context.read<AdPostingCubit>().state.adPostingData.category!;

    // Initialize Language Notifier
    final languages = Constant.systemSettings.languages;
    final defaultLanguage = languages.firstWhere((l) => l.isDefault);
    _languageNotifier = ValueNotifier(defaultLanguage);

    _initializeFields();

    _formattedCurrency = _currencyNotifier.value;
    _currencyNotifier.addListener(_onCurrencyChanged);
  }

  void _onCurrencyChanged() {
    final from = _formattedCurrency;
    final to = _currencyNotifier.value;
    _formattedCurrency = to;
    for (final controller in [
      _priceController,
      _minSalaryController,
      _maxSalaryController,
    ]) {
      if (controller == null || controller.text.isEmpty) continue;
      controller.text = _reformat(controller.text, from: from, to: to);
    }
  }

  /// Runs the text through the new currency's [CurrencyFormatter] as if it
  /// had been typed, so nothing is padded or truncated beyond what the
  /// formatter itself would do.
  String _reformat(
    String text, {
    required Currency from,
    required Currency to,
  }) {
    final plain = text.normalize(from);
    final value = double.tryParse(plain);
    if (value == null) return text;
    // Drop the padding `normalize` adds; keep only what the user typed.
    var raw = value.toString();
    if (raw.endsWith('.0')) raw = raw.substring(0, raw.length - 2);
    raw = raw.replaceAll('.', to.decimalSeparator ?? '.');
    return CurrencyFormatter(to)
        .formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: raw))
        .text;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _currencyNotifier.removeListener(_onCurrencyChanged);
    _priceController?.dispose();
    _minSalaryController?.dispose();
    _maxSalaryController?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateButtonState();
  }

  void _updateButtonState() {
    if (!mounted) return;

    final customFieldsState = context.read<CustomFieldsCubit>().state;
    final adPostingState = context.read<AdPostingCubit>().state;

    final isLoading =
        customFieldsState is CustomFieldsLoading ||
        adPostingState.isFetchingReel;

    AdPostingStepController.of(
      context,
    ).register(onNext: isLoading ? null : _onNext, showNext: true);
  }

  Future<void> _onNext() async {
    if (_languageNotifier.value.isDefault && !await _validateFields()) {
      return;
    }
    if (_languageNotifier.value.isDefault) {
      _updateBasicDetails();
    } else {
      _updateLocalizedContent(_languageNotifier.value);
    }
    if (context.mounted) {
      context.read<AdPostingCubit>().nextStep();
    }
  }

  void _initializeFields() {
    final data = context.read<AdPostingCubit>().state.adPostingData;

    // Initialize Basic Detail Fields
    final basicDetails = data.basicDetails;

    _titleController = TextController(text: basicDetails?.title ?? '');
    _descriptionController = TextController(
      text: basicDetails?.description ?? '',
    );
    _phoneController = PhoneInputController(
      contact: basicDetails?.contact ?? AppSession.currentUser?.contact,
    );
    _adSlugController = TextController(text: basicDetails?.slug ?? '');

    if (basicDetails?.price == null) {
      if (_category.isJobCategory) {
        _minSalaryController = TextController();
        _maxSalaryController = TextController();
        _priceController = null;
      } else {
        _priceController = TextController();
        _minSalaryController = null;
        _maxSalaryController = null;
      }
      _currencyNotifier = ValueNotifier(
        context.read<CurrenciesCubit>().getSelectedCurrency(),
      );
    } else {
      if (basicDetails!.price case final DraftSalary salary) {
        _priceController = null;
        _minSalaryController = TextController(text: salary.minSalary);
        _maxSalaryController = TextController(text: salary.maxSalary);
      } else {
        _priceController = TextController(
          text: (basicDetails.price as DraftPrice).price,
        );
        _minSalaryController = null;
        _maxSalaryController = null;
      }
      _currencyNotifier = ValueNotifier(basicDetails.price!.currency);
    }

    _seoController = SEODetailsController(data.seoData);
  }

  void _generateSlug(String title) {
    // force lowercase
    String slug = title.toLowerCase();

    // replace anything that is NOT english letters a-z or digits 0-9 with "-"
    slug = slug.replaceAll(RegExp(r'[^a-z0-9]+'), '-');

    // trim leading/trailing "-"
    slug = slug.replaceAll(RegExp(r'^-+|-+$'), '');

    _adSlugController.text = slug;
  }

  Future<bool> _validateFields() async {
    var isValid = true;

    isValid &= _titleController.validate();
    isValid &= _descriptionController.validate();

    if (!_category.isPriceOptional) {
      if (_category.isJobCategory) {
        isValid &= _minSalaryController!.validate();
        isValid &= _maxSalaryController!.validate();
      } else {
        isValid &= _priceController!.validate();
      }
    }

    isValid &= await _phoneController.validateAsync();
    isValid &= _adSlugController.validate();

    return isValid;
  }

  void _updateBasicDetails() {
    final details = BasicDetails(
      title: _titleController.text,
      slug: _adSlugController.text,
      description: _descriptionController.text,
      price: _category.isJobCategory
          ? DraftSalary(
              minSalary: _minSalaryController!.text,
              maxSalary: _maxSalaryController!.text,
              currency: _currencyNotifier.value,
            )
          : DraftPrice(
              price: _priceController!.text,
              currency: _currencyNotifier.value,
            ),
      contact: _phoneController.contact,
    );

    final seoData = _seoController.values;

    context.read<AdPostingCubit>().updateData(
      (data) => data.copyWith(basicDetails: details, seoData: seoData),
    );
  }

  void _updateLocalizedContent(Language language) {
    final content = LocalizedContent(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    context.read<AdPostingCubit>().updateData(
      (data) =>
          data.copyWith(localizedContentEntry: MapEntry(language.id, content)),
    );
  }

  void _loadLanguageData(Language language) {
    final data = context.read<AdPostingCubit>().state.adPostingData;
    if (language.isDefault) {
      _titleController.text = data.basicDetails?.title ?? '';
      _descriptionController.text = data.basicDetails?.description ?? '';
    } else {
      final content = data.localizedContent?[language.id];
      _titleController.text = content?.title ?? '';
      _descriptionController.text = content?.description ?? '';
    }

    // SEO Data is handled by the SEODetails widget implicitly so there is
    // no need to load it manually here
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CustomFieldsCubit, CustomFieldsState>(
          listener: (context, state) => _updateButtonState(),
        ),
        BlocListener<AdPostingCubit, AdPostingState>(
          listenWhen: (previous, current) =>
              previous.isFetchingReel != current.isFetchingReel,
          listener: (context, state) => _updateButtonState(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: context.bodyPadding(),
              child: ValueListenableBuilder(
                valueListenable: _languageNotifier,
                builder: (context, language, child) {
                  final isDefault = language.isDefault;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 16,
                    children: [
                      LanguageTabBar(
                        onLanguageChanged: (language) async {
                          if (_languageNotifier.value.isDefault &&
                              !await _validateFields()) {
                            return false;
                          }
                          if (_languageNotifier.value.isDefault) {
                            _updateBasicDetails();
                          } else {
                            _updateLocalizedContent(_languageNotifier.value);
                          }
                          _languageNotifier.value = language;
                          _loadLanguageData(language);
                          return true;
                        },
                      ),
                      FieldSkeleton(
                        title: 'adTitle',
                        isRequired: language.isDefault,
                        child: CustomTextField(
                          controller: _titleController,
                          hintKey: 'adTitle',
                          onChanged: language.isDefault ? _generateSlug : null,
                        ),
                      ),
                      FieldSkeleton(
                        title: 'adDescription',
                        isRequired: language.isDefault,
                        action:
                            BlocConsumer<
                              GenerateDescriptionCubit,
                              GenerateDescriptionState
                            >(
                              listener: (context, state) {
                                if (state is GenerateDescriptionSuccess) {
                                  _descriptionController.text =
                                      state.description;
                                }
                                if (state is GenerateDescriptionFailure) {
                                  HelperUtils.showSnackBarMessage(
                                    context,
                                    state.errorMessage,
                                  );
                                }
                              },
                              builder: (context, state) {
                                return AIGenerateButton(
                                  isLoading:
                                      state is GenerateDescriptionInProgress,
                                  onPressed: () {
                                    if (_titleController.text.trim().isEmpty) {
                                      HelperUtils.showSnackBarMessage(
                                        context,
                                        'titleIsRequiredForAIGeneration'
                                            .translate(context),
                                      );
                                      return;
                                    }

                                    final title = _titleController.text.trim();
                                    final price = _category.isJobCategory
                                        ? HelperUtils.formattedSalaryRange(
                                            _minSalaryController?.text ?? '',
                                            _maxSalaryController?.text ?? '',
                                          )
                                        : (_priceController?.text ?? '');

                                    context
                                        .read<GenerateDescriptionCubit>()
                                        .generate(
                                          title: title,
                                          price: price,
                                          languageId: language.id.toString(),
                                          category: _category.name.localized,
                                          currencyISOCode:
                                              _currencyNotifier.value.code,
                                        );
                                  },
                                );
                              },
                            ),
                        child: CustomTextField(
                          controller: _descriptionController,
                          hintKey: 'adDescription',
                          minLines: 5,
                          maxLines: 10,
                          textAlignVertical: TextAlignVertical.top,
                        ),
                      ),
                      if (isDefault)
                        ValueListenableBuilder(
                          valueListenable: _currencyNotifier,
                          builder: (context, currency, child) {
                            if (_category.isJobCategory) {
                              return FieldSkeleton(
                                title: 'salary',
                                isRequired: !_category.isPriceOptional,
                                child: Row(
                                  spacing: 15,
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _minSalaryController!,
                                        hintKey: 'min',
                                        textInputType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        prefixIcon: CurrencyPrefixWidget(
                                          currencyNotifier: _currencyNotifier,
                                        ),
                                        validators: [
                                          if (!_category.isPriceOptional)
                                            EmptyFieldValidator(),
                                          NumericComparisonValidator(
                                            getCompareValue: () =>
                                                _maxSalaryController!.text,
                                            operator:
                                                ComparisonOperator.lessThan,
                                            errorText:
                                                'minSalaryMustBeLessThanMax',
                                          ),
                                        ],
                                        formatters: [
                                          CurrencyFormatter(currency),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _maxSalaryController!,
                                        hintKey: 'max',
                                        textInputType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        prefixIcon: CurrencyPrefixWidget(
                                          currencyNotifier: _currencyNotifier,
                                        ),
                                        validators: [
                                          if (!_category.isPriceOptional)
                                            EmptyFieldValidator(),
                                          NumericComparisonValidator(
                                            getCompareValue: () =>
                                                _minSalaryController.text,
                                            operator:
                                                ComparisonOperator.greaterThan,
                                            errorText:
                                                'maxSalaryMustBeGreaterThanMin',
                                          ),
                                        ],
                                        formatters: [
                                          CurrencyFormatter(currency),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return FieldSkeleton(
                                title: 'price',
                                isRequired: !_category.isPriceOptional,
                                child: CustomTextField(
                                  controller: _priceController!,
                                  hintKey: 'price',
                                  textInputType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                  prefixIcon: CurrencyPrefixWidget(
                                    currencyNotifier: _currencyNotifier,
                                  ),
                                  validators: [
                                    if (!_category.isPriceOptional)
                                      EmptyFieldValidator(),
                                  ],
                                  formatters: [CurrencyFormatter(currency)],
                                ),
                              );
                            }
                          },
                        ),

                      if (isDefault)
                        FieldSkeleton(
                          title: 'phoneNumber',
                          child: PhoneInput(
                            controller: _phoneController,
                            required: false,
                          ),
                        ),
                      if (isDefault)
                        FieldSkeleton(
                          title: 'adSlug',
                          child: CustomTextField(
                            controller: _adSlugController,
                            hintKey: 'adSlug',
                            validators: [SlugValidator()],
                            formatters: [SlugFormatter()],
                          ),
                        ),
                      if (Constant.showSEOFields)
                        SEODetails(
                          controller: _seoController,
                          languageId: language.id,
                          onAIGenerate: () {
                            if (_titleController.text.trim().isEmpty) {
                              HelperUtils.showSnackBarMessage(
                                context,
                                'titleIsRequiredForAIGeneration'.translate(
                                  context,
                                ),
                              );
                              return;
                            }

                            final title = _titleController.text.trim();
                            final price = _category.isJobCategory
                                ? HelperUtils.formattedSalaryRange(
                                    _minSalaryController?.text ?? '',
                                    _maxSalaryController?.text ?? '',
                                  )
                                : (_priceController?.text ?? '');

                            context.read<GenerateMetaCubit>().generate(
                              title: title,
                              price: price,
                              languageId: language.id.toString(),
                              currencyISOCode: _currencyNotifier.value.code,
                              category: _category.name.localized,
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
