import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eClassify/app/config/app_config.dart';
import 'package:eClassify/features/jobs/cubits/apply_job_application_cubit.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/inputs/custom_text_field.dart';
import 'package:eClassify/core/widgets/inputs/phone_input.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/network/api.dart';
import 'package:eClassify/core/network/api_params.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/file_picker_utility.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_file/open_file.dart';

class JobApplicationForm extends StatefulWidget {
  const JobApplicationForm({Key? key, required this.itemId}) : super(key: key);
  final int itemId;

  @override
  _JobApplicationFormState createState() => _JobApplicationFormState();

  static Route route(RouteSettings routeSettings) {
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => BlocProvider(
        create: (context) => ApplyJobApplicationCubit(),
        child: JobApplicationForm(itemId: routeSettings.arguments as int),
      ),
    );
  }
}

class _JobApplicationFormState extends State<JobApplicationForm> {
  //Text Controllers
  final TextController nameController = TextController();
  final TextController emailController = TextController();
  final PhoneInputController phoneController = PhoneInputController();
  File? pickedFile;
  bool isBack = false;

  @override
  void initState() {
    super.initState();
    final userDetails = AppSession.currentUser!;
    nameController.text = userDetails.name;
    emailController.text = userDetails.email;
    phoneController.contact = userDetails.contact.copyWith(
      callingCode: userDetails.contact.callingCode.replaceAll('+', ''),
      regionCode: userDetails.contact.regionCode.isEmpty
          ? AppConfig.defaultCountryCode
          : userDetails.contact.regionCode,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplyJobApplicationCubit, ApplyJobApplicationState>(
      listener: (context, state) {
        if (state is ApplyJobApplicationSuccess) {
          HelperUtils.showSnackBarMessage(context, state.successMessage);
          Navigator.of(context).pop(true);
        }
        if (state is ApplyJobApplicationFail) {
          HelperUtils.showSnackBarMessage(context, state.error);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: isBack,
          onPopInvokedWithResult: (didPop, result) {
            setState(() {
              isBack = state is! ApplyJobApplicationInProgress;
            });
          },
          child: AppScaffold(
            appBar: AppBar(
              title: Text("jobApplicationForm".translate(context)),
            ),
            body: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildTextField(
                    context,
                    title: "fullName",
                    hintKey: "provideFullNameHere",
                    controller: nameController,
                    validators: [EmptyFieldValidator()],
                  ),
                  SizedBox(height: 10),
                  Text("mobileNumber".translate(context)),
                  SizedBox(height: 10),
                  PhoneInput(controller: phoneController),
                  buildTextField(
                    context,
                    title: "emailAddress",
                    hintKey: "emailAddressHere",
                    controller: emailController,
                    validators: [EmptyFieldValidator(), EmailValidator()],
                  ),
                  _JobAttachment(
                    pickedFile: pickedFile,
                    onFilePicked: (file) {
                      setState(() {
                        pickedFile = file;
                      });
                    },
                  ),
                  SizedBox(height: 25),
                  state is ApplyJobApplicationInProgress
                      ? Center(
                          child: CircularProgressIndicator(
                            color: context.colorScheme.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : AppButton(
                          variant: AppButtonVariant.filled,
                          size: AppButtonSize.small,
                          foregroundColor: context.colorScheme.onPrimary,
                          backgroundColor: context.colorScheme.primary,
                          onPressed: () async {
                            if (state is ApplyJobApplicationInProgress) return;
                            bool isPhoneValid = await phoneController
                                .validateAsync();
                            bool isFormValid =
                                nameController.validate() &
                                emailController.validate();
                            if (isFormValid && isPhoneValid) {
                              Map<String, dynamic> data = {};
                              data['item_id'] = widget.itemId;
                              data['full_name'] = nameController.text;
                              data['email'] = emailController.text;
                              data['mobile'] = phoneController.contact.number;
                              data['phone_code'] =
                                  phoneController.contact.callingCode;
                              data[ApiParams.regionCode] =
                                  phoneController.contact.regionCode;

                              context
                                  .read<ApplyJobApplicationCubit>()
                                  .applyJobApplication(data, pickedFile);
                            }
                          },
                          title: "enquireNow",
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildTextField(
    BuildContext context, {
    required String title,
    required TextController controller,
    List<Validator<String?>>? validators,
    bool readOnly = false,
    required String hintKey,
  }) {
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text(title.translate(context)),
        CustomTextField(
          controller: controller,
          readOnly: readOnly,
          validators: validators,
          hintKey: hintKey,
          fillColor: context.colorScheme.secondary,
        ),
      ],
    );
  }
}

class _JobAttachment extends StatelessWidget {
  final File? pickedFile;
  final Function(File?) onFilePicked;

  const _JobAttachment({
    Key? key,
    required this.pickedFile,
    required this.onFilePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text("attachResumeIfAny".translate(context)),
        SizedBox(height: 10),
        DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: context.mutedColor,
            radius: const Radius.circular(12),
          ),
          child: GestureDetector(
            onTap: () async {
              List<File>? result = await FilePickerUtility.pick(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx'],
              );

              if (result != null && result.isNotEmpty) {
                onFilePicked(result.first);
              }
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: AlignmentDirectional.center,
              height: 48,
              child: Text(
                "uploadFile".translate(context),
                style: context.bodyLarge,
              ),
            ),
          ),
        ),
        if (pickedFile != null)
          AppButton(
            variant: AppButtonVariant.text,
            width: AppButtonWidth.content,
            onPressed: () => OpenFile.open(pickedFile!.path),
            child: Text(pickedFile!.path.split('/').last),
          ),
      ],
    );
  }
}
