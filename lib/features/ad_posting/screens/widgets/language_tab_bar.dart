import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/models/language.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/widgets/layout/app_tab_bar.dart';
import 'package:flutter/material.dart';

class LanguageTabBar extends StatefulWidget {
  const LanguageTabBar({required this.onLanguageChanged, super.key});

  final Future<bool> Function(Language) onLanguageChanged;

  @override
  State<LanguageTabBar> createState() => _LanguageTabBarState();
}

class _LanguageTabBarState extends State<LanguageTabBar>
    with SingleTickerProviderStateMixin {
  final languages = Constant.systemSettings.languages
    ..sort((a, b) {
      if (a.isDefault == b.isDefault) return 0;
      return a.isDefault ? -1 : 1;
    });
  late final _tabController = TabController(
    animationDuration: const Duration(milliseconds: 300),
    length: languages.length,
    vsync: this,
  );

  @override
  Widget build(BuildContext context) {
    if (Constant.systemSettings.languages.length <= 1) {
      return const SizedBox.shrink();
    }

    return AppTabBar(
      controller: _tabController,
      applyDesignStyle: false,
      padding: EdgeInsets.zero,
      selectedTabColor: context.colorScheme.primary.withValues(alpha: .1),
      selectedBorderColor: context.colorScheme.primary,
      unselectedBorderColor: context.theme.dividerColor,
      selectedTextColor: context.colorScheme.onSurface,
      tabs: languages.map((l) => l.name).toList(),
      onChanged: (index) async {
        final shouldChange = await widget.onLanguageChanged(languages[index]);
        if (!shouldChange) {
          _tabController.animateTo(0);
        }
      },
    );
  }
}
