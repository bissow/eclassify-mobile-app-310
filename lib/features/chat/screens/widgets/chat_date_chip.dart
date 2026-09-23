import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDateChip extends StatelessWidget {
  const ChatDateChip({required this.date, super.key});

  final DateTime date;

  String _getRelativeDate(BuildContext context) {
    final now = DateTime.now();
    if (DateUtils.isSameDay(now, date)) {
      return 'today'.translate(context);
    } else if (DateUtils.isSameDay(
      now.subtract(const Duration(days: 1)),
      date,
    )) {
      return 'yesterday'.translate(context);
    } else {
      return date.format(formatString: DateFormat.YEAR_MONTH_DAY);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        color: context.colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            _getRelativeDate(context),
            style: context.labelLarge.withColor(context.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
