import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/features/chat/cubits/chat_message_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_session_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_template_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatTemplateList extends StatelessWidget {
  const ChatTemplateList({super.key});

  @override
  Widget build(BuildContext context) {
    final showTemplates = context.select<ChatSessionCubit, bool>(
      (c) => c.state.showTemplates,
    );
    return BlocBuilder<ChatTemplateCubit, List<String>>(
      builder: (context, templates) {
        if (templates.isEmpty) {
          return const SizedBox.shrink();
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 12,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constant.horizontalPadding,
                  vertical: 12,
                ),
                child: GestureDetector(
                  onTap: () {
                    context.read<ChatSessionCubit>().toggleTemplates();
                  },
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(AppIcons.starFour, size: 16),
                      Expanded(
                        child: Text(
                          'quickReplies'.translate(context),
                          style: context.labelMedium,
                        ),
                      ),
                      Icon(
                        showTemplates ? AppIcons.caretDown : AppIcons.caretUp,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutQuad,
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: showTemplates ? 48 : 0,
                  child: ListView.separated(
                    padding: EdgeInsetsDirectional.only(
                      start: Constant.horizontalPadding,
                      end: Constant.horizontalPadding,
                      bottom: 16,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: templates.length,
                    itemBuilder: (context, index) =>
                        _TemplateChip(data: templates[index]),
                    separatorBuilder: (_, _) => 8.hGap,
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}

class _TemplateChip extends StatelessWidget {
  const _TemplateChip({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<ChatMessageCubit>().sendMessage(text: data);
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(data, style: context.bodySmall),
        ),
      ),
    );
  }
}
