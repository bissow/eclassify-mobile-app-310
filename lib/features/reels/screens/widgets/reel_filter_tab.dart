import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ReelFilterTab extends StatefulWidget {
  const ReelFilterTab({required this.onChanged, super.key});

  final ValueChanged<bool> onChanged;

  @override
  State<ReelFilterTab> createState() => _ReelFilterTabState();
}

class _ReelFilterTabState extends State<ReelFilterTab> {
  bool isFollowingTab = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (!isFollowingTab) return;
            setState(() {
              isFollowingTab = false;
            });
            widget.onChanged(isFollowingTab);
          },
          child: Text(
            'forYou'.translate(context),
            style: context.titleMedium.copyWith(
              color: isFollowingTab
                  ? Colors.white.withValues(alpha: .6)
                  : Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: 16,
          child: VerticalDivider(color: Colors.white.withValues(alpha: .6)),
        ),
        GestureDetector(
          onTap: () {
            if (isFollowingTab) return;
            setState(() {
              isFollowingTab = true;
            });
            widget.onChanged(isFollowingTab);
          },
          child: Text(
            'following'.translate(context),
            style: context.titleMedium.copyWith(
              color: isFollowingTab
                  ? Colors.white
                  : Colors.white.withValues(alpha: .6),
            ),
          ),
        ),
      ],
    );
  }
}
