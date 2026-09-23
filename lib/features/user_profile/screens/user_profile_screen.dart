import 'package:eClassify/features/auth/cubits/auth_session_cubit.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';
import 'package:eClassify/features/auth/models/user.dart';
import 'package:eClassify/features/user_profile/cubits/user_profile_cubit.dart';
import 'package:eClassify/core/models/file_resource.dart';
import 'package:eClassify/features/user_profile/screens/profile_image_widget.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/phone_input.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({required this.user, super.key});

  final User? user;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => UserProfileScreen(user: routeSettings.arguments as User?),
    );
  }
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final User _user = widget.user ?? AppSession.currentUser!;

  late final TextController _nameController;
  late final TextController _emailController;
  late final PhoneInputController _phoneController;
  late final TextController _addressController;
  late final ValueNotifier<bool> _notificationsEnabled;
  late final ValueNotifier<bool> _showPersonalDetails;
  late final ValueNotifier<FileResource?> _profileImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextController(text: _user.name);
    _emailController = TextController(text: _user.email);
    _phoneController = PhoneInputController(contact: _user.contact);
    _addressController = TextController(text: _user.address);
    _notificationsEnabled = ValueNotifier(_user.notificationsEnabled);
    _showPersonalDetails = ValueNotifier(_user.showPersonalDetails);
    final profile = _user.profile.isNullOrEmpty
        ? null
        : FileResource.fromPath(_user.profile!);
    _profileImage = ValueNotifier(profile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notificationsEnabled.dispose();
    _showPersonalDetails.dispose();
    _profileImage.dispose();
    super.dispose();
  }

  void _updateProfile() async {
    final current = context.read<UserProfileCubit>().state;
    if (current is UserProfileLoading && current.isUpdate) {
      return;
    }

    bool hasValidFields = true;

    hasValidFields &= _nameController.validate() & _emailController.validate();

    hasValidFields &=
        !_phoneController.text.isNotNullAndNotEmpty ||
        await _phoneController.validateAsync();

    if (_profileImage.value case LocalFileResource r) {
      final imageSize = r.file.lengthSync();
      if (imageSize > 7 * 1024 * 1024) {
        HelperUtils.showSnackBarMessage(
          context,
          'profileImageSizeExceededError'.translate(context),
        );
        hasValidFields &= false;
      }
    }

    if (!hasValidFields) return;

    if (_phoneController.text.isNullOrEmpty) {
      _phoneController.clear();
    }

    final updatedUser = _user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      contact: _phoneController.contact,
      notificationsEnabled: _notificationsEnabled.value,
      showPersonalDetails: _showPersonalDetails.value,
    );

    context.read<UserProfileCubit>().updateUserProfile(
      updatedUser,
      profileImagePath: switch (_profileImage.value) {
        LocalFileResource(:final file) => file.path,
        _ => null,
      },
    );
  }

  Widget _titleAndField({
    required String title,
    required Widget field,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4,
          children: [
            Text(title.translate(context), style: context.labelLarge),
            if (required) const Text('*', style: TextStyle(color: Colors.red)),
          ],
        ),
        4.vGap,
        field,
      ],
    );
  }

  Widget _toggleSwitch({
    required String title,
    required ValueNotifier<bool> notifier,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: context.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
        color: context.colorScheme.secondary,
      ),
      child: Padding(
        padding:
            context.theme.inputDecorationTheme.contentPadding ??
            EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(title.translate(context), style: context.labelLarge),
            ),
            ValueListenableBuilder(
              valueListenable: notifier,
              builder: (context, value, child) {
                return Switch(
                  value: value,
                  onChanged: (newValue) => notifier.value = newValue,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFromLogin = widget.user != null;
    return PopScope(
      canPop: !isFromLogin,
      child: AutofillGroup(
        child: BlocListener<UserProfileCubit, UserProfileState>(
          listener: (context, state) {
            // Ignore anything this screen did not start; the cubit is
            // global and HomeScreen fetches through it on mount.
            if (state is! UserProfileOperationState || !state.isUpdate) return;

            if (state is UserProfileSuccess) {
              if (state.message != null && !isFromLogin) {
                HelperUtils.showSnackBarMessage(context, state.message!);
              }
              if (isFromLogin) {
                Navigator.of(context).pop(state.user);
              } else {
                context.read<AuthSessionCubit>().updateSession(state.user);
              }
            }
            if (state is UserProfileFailure) {
              HelperUtils.showSnackBarMessage(context, state.error.toString());
            }
          },
          child: AppScaffold(
            appBar: AppBar(
              title: Text('profile'.translate(context)),
              automaticallyImplyLeading: !isFromLogin,
            ),
            bottomAction: BlocBuilder<UserProfileCubit, UserProfileState>(
              builder: (context, state) {
                final isLoading = state is UserProfileLoading && state.isUpdate;
                return AppButton(
                  variant: AppButtonVariant.filled,
                  onPressed: _updateProfile,
                  child: isLoading
                      ? LoadingIndicator.inlineDots()
                      : Text('updateProfile'.translate(context)),
                );
              },
            ),
            body: SingleChildScrollView(
              padding: context.bodyPadding(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  Center(
                    child: ProfileImageWidget(
                      profileImageNotifier: _profileImage,
                    ),
                  ),
                  8.vGap,
                  _titleAndField(
                    title: 'fullName',
                    field: CustomTextField(
                      controller: _nameController,
                      hintKey: 'fullName',
                      autoFillHints: const [AutofillHints.name],
                    ),
                    required: true,
                  ),
                  _titleAndField(
                    title: 'emailAddress',
                    field: CustomTextField(
                      controller: _emailController,
                      validators: [EmptyFieldValidator(), EmailValidator()],
                      readOnly: _user.authProvider == AuthProvider.email,
                      hintKey: 'emailAddress',
                      autoFillHints: const [AutofillHints.email],
                    ),
                    required: true,
                  ),
                  _titleAndField(
                    title: 'phoneNumber',
                    field: PhoneInput(
                      controller: _phoneController,
                      required: false,
                      readOnly: _user.authProvider == AuthProvider.phone,
                    ),
                  ),
                  _titleAndField(
                    title: 'address',
                    field: CustomTextField(
                      controller: _addressController,
                      minLines: 2,
                      maxLines: 5,
                      validators: const [],
                      hintKey: 'address',
                      autoFillHints: const [AutofillHints.postalAddress],
                    ),
                  ),
                  _toggleSwitch(
                    title: 'notification',
                    notifier: _notificationsEnabled,
                  ),
                  _toggleSwitch(
                    title: 'showContactInfo',
                    notifier: _showPersonalDetails,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
