import 'dart:convert';
import 'dart:io';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/file_picker_utility.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/location/models/leaf_location.dart';
import 'package:eClassify/features/store/cubits/my_store_cubit.dart';
import 'package:eClassify/features/store/cubits/store_setup_cubit.dart';
import 'package:eClassify/features/store/models/store_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StoreSetupScreen extends StatefulWidget {
  const StoreSetupScreen({this.existingStore, super.key});

  final StoreModel? existingStore;

  static Route route(RouteSettings settings) {
    final store = settings.arguments as StoreModel?;
    return MaterialPageRoute(
      builder: (context) => BlocProvider(
        create: (_) => StoreSetupCubit(),
        child: StoreSetupScreen(existingStore: store),
      ),
    );
  }

  @override
  State<StoreSetupScreen> createState() => _StoreSetupScreenState();
}

class _StoreSetupScreenState extends State<StoreSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _websiteController;
  late final TextEditingController _taxNumberController;
  late final TextEditingController _openingTimeController;
  late final TextEditingController _closingTimeController;

  File? _logoFile;
  File? _bannerFile;
  LeafLocation? _selectedLocation;
  List<String> _selectedDays = [];

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.existingStore;
    _nameController = TextEditingController(text: s?.name ?? '');
    _descController = TextEditingController(text: s?.description ?? '');
    _contactController = TextEditingController(text: s?.contact ?? '');
    _emailController = TextEditingController(text: s?.email ?? '');
    _addressController = TextEditingController(text: s?.address ?? '');
    _websiteController = TextEditingController(text: s?.website ?? '');
    _taxNumberController = TextEditingController(text: s?.taxNumber ?? '');
    _openingTimeController = TextEditingController(text: s?.openingTime ?? '09:00');
    _closingTimeController = TextEditingController(text: s?.closingTime ?? '20:00');

    if (s?.workingDays != null) {
      _selectedDays = List<String>.from(s!.workingDays!);
    } else {
      _selectedDays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    }

    if (s != null && s.latitude != null && s.longitude != null) {
      _selectedLocation = LeafLocation(
        latitude: s.latitude,
        longitude: s.longitude,
        country: null,
        city: null,
        state: null,
        primaryText: s.city ?? s.address,
        secondaryText: s.state,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _taxNumberController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final files = await FilePickerUtility.pickWithSheet(context: context);
    if (files != null && files.isNotEmpty) {
      setState(() {
        _logoFile = files.first;
      });
    }
  }

  Future<void> _pickBanner() async {
    final files = await FilePickerUtility.pickWithSheet(context: context);
    if (files != null && files.isNotEmpty) {
      setState(() {
        _bannerFile = files.first;
      });
    }
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.pushNamed(context, Routes.locationScreen)
        as LeafLocation?;
    if (result != null && mounted) {
      setState(() {
        _selectedLocation = result;
        if (_addressController.text.isEmpty && result.localizedPath.isNotEmpty) {
          _addressController.text = result.localizedPath;
        }
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final loc = _selectedLocation ?? AppSession.currentLocation;

    final fields = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'contact': _contactController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'website': _websiteController.text.trim(),
      'tax_number': _taxNumberController.text.trim(),
      'opening_time': _openingTimeController.text.trim(),
      'closing_time': _closingTimeController.text.trim(),
      'working_days': jsonEncode(_selectedDays),
    };

    if (loc != null) {
      if (loc.latitude != null) fields['latitude'] = loc.latitude;
      if (loc.longitude != null) fields['longitude'] = loc.longitude;
      if (loc.country != null) fields['country'] = loc.country!.canonical;
      if (loc.state != null) fields['state'] = loc.state!.canonical;
      if (loc.city != null) fields['city'] = loc.city!.canonical;
    }

    context.read<StoreSetupCubit>().saveStore(
          fields: fields,
          logoFile: _logoFile,
          bannerFile: _bannerFile,
        );
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefixIcon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: context.bodySmall.withColor(context.mutedColor),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.grey.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.25),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.25),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: context.colorScheme.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingStore != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Store / Shop' : 'Setup Store / Shop',
        ),
      ),
      body: BlocConsumer<StoreSetupCubit, StoreSetupState>(
        listener: (context, state) {
          if (state is StoreSetupSuccess) {
            context.read<MyStoreCubit>().updateStore(state.store);
            HelperUtils.showSnackBarMessage(
              context,
              'Store details saved successfully!',
            );
            Navigator.pop(context, state.store);
          }
          if (state is StoreSetupFailure) {
            HelperUtils.showSnackBarMessage(
              context,
              state.error.toString(),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is StoreSetupLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Image Uploader
                  Text(
                    'Cover Banner',
                    style: context.bodyMedium.semiBold,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickBanner,
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.3),
                          style: BorderStyle.solid,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _bannerFile != null
                          ? Image.file(_bannerFile!, fit: BoxFit.cover)
                          : (widget.existingStore?.banner != null &&
                                  widget.existingStore!.banner!.isNotEmpty
                              ? CustomImage(
                                  src: widget.existingStore!.banner!,
                                  fit: BoxFit.cover,
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      AppIcons.cameraPlus,
                                      size: 32,
                                      color: context.colorScheme.primary,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Upload store cover banner (16:9)',
                                      style: context.bodySmall.withColor(context.mutedColor),
                                    ),
                                  ],
                                )),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Store Logo Uploader
                  Text(
                    'Store Logo',
                    style: context.bodyMedium.semiBold,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Row(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey.withValues(alpha: 0.1),
                            border: Border.all(
                              color: context.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _logoFile != null
                              ? Image.file(_logoFile!, fit: BoxFit.cover)
                              : (widget.existingStore?.logo != null &&
                                      widget.existingStore!.logo!.isNotEmpty
                                  ? CustomImage(
                                      src: widget.existingStore!.logo!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      AppIcons.cameraPlus,
                                      size: 24,
                                      color: context.colorScheme.primary,
                                    )),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tap to upload store avatar/logo',
                                style: context.bodySmall.semiBold,
                              ),
                              Text(
                                'Recommended: 1:1 square ratio, JPG or PNG',
                                style: context.bodySmall.withColor(context.mutedColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Store Name
                  Text('Store / Shop Name *', style: context.bodyMedium.semiBold),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    decoration: _inputDecoration('e.g. Acme Superstore'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Please enter store name' : null,
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text('Description', style: context.bodyMedium.semiBold),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: _inputDecoration('Tell customers about your store, products & services...'),
                  ),
                  const SizedBox(height: 16),

                  // Location Picker
                  Text('Store Location *', style: context.bodyMedium.semiBold),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickLocation,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(AppIcons.mapPinFill, color: context.colorScheme.primary, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _selectedLocation?.localizedPath.isNotEmpty == true
                                  ? _selectedLocation!.localizedPath
                                  : (widget.existingStore?.address ?? 'Select store location'),
                              style: context.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(AppIcons.caretRight, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Address Details
                  Text('Detailed Address', style: context.bodyMedium.semiBold),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _addressController,
                    decoration: _inputDecoration('Street, building number, landmark...'),
                  ),
                  const SizedBox(height: 16),

                  // Contact Phone & Email in a Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact Phone', style: context.bodyMedium.semiBold),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _contactController,
                              keyboardType: TextInputType.phone,
                              decoration: _inputDecoration('e.g. 9876543210'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Contact Email', style: context.bodyMedium.semiBold),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: _inputDecoration('store@example.com'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Website & Tax Number in a Row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Website', style: context.bodyMedium.semiBold),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _websiteController,
                              decoration: _inputDecoration('https://...'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tax / VAT #', style: context.bodyMedium.semiBold),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _taxNumberController,
                              decoration: _inputDecoration('e.g. TAX-12345'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Working Hours (Opening & Closing)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Opening Time', style: context.bodyMedium.semiBold),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _openingTimeController,
                              decoration: _inputDecoration('09:00'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Closing Time', style: context.bodyMedium.semiBold),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _closingTimeController,
                              decoration: _inputDecoration('20:00'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Working Days Selection
                  Text('Working Days', style: context.bodyMedium.semiBold),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _daysOfWeek.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day.substring(0, 3)),
                        selected: isSelected,
                        selectedColor: context.colorScheme.primary.withValues(alpha: 0.2),
                        checkmarkColor: context.colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? context.colorScheme.primary
                              : context.mutedColor,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),

                  // Save / Submit Button
                  AppButton(
                    variant: AppButtonVariant.filled,
                    onPressed: isLoading ? null : _submit,
                    title: isEditing ? 'Save Changes' : 'Create Store',
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: LoadingIndicator(),
                          )
                        : null,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
