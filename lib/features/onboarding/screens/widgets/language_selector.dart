import 'package:eClassify/app/routes.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/cubits/language_cubit.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languages = Constant.systemSettings.languages;
    final defaultLanguage = Constant.systemSettings.defaultLanguage;
    if (languages.length <= 1) {
      return const SizedBox.shrink();
    }
    // To re-build widget when the language is changed from within the language screen
    context.watch<LanguageCubit>();
    // AppSession.currentLanguage will already be containing latest value
    final currentLanguage = AppSession.currentLanguage;
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: context.colorScheme.onSurface,
        iconColor: context.colorScheme.primary,
        iconSize: 30,
        padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
      ),
      onPressed: () {
        Navigator.pushNamed(context, Routes.languageListScreen);
      },
      child: Row(
        spacing: 4,
        children: [
          Text(
            (currentLanguage?.languageCode ?? defaultLanguage.languageCode)
                .toUpperCase(),
          ),
          Icon(AppIcons.caretDown, size: 16),
        ],
      ),
    );
  }
}
