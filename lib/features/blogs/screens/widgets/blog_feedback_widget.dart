import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/debounce_mixin.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/blogs/cubits/blog_feedback_cubit.dart';
import 'package:eClassify/features/blogs/models/blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlogFeedbackWidget extends StatefulWidget {
  const BlogFeedbackWidget({required this.blog, super.key});

  final Blog blog;

  @override
  State<BlogFeedbackWidget> createState() => _BlogFeedbackWidgetState();
}

class _BlogFeedbackWidgetState extends State<BlogFeedbackWidget>
    with DebounceMixin<BlogFeedbackWidget, BlogFeedback?> {
  // Track current selection and count locally for responsive optimistic updates
  late BlogFeedback? _currentFeedback = widget.blog.userFeedback;

  // Track the actual backend-persisted state to correctly detect redundant actions
  late BlogFeedback? _lastSavedFeedback = widget.blog.userFeedback;
  late int _usefulCount = widget.blog.usefulCount;
  late int _notUsefulCount = widget.blog.notUsefulCount;

  @override
  Duration get debounceDuration => const Duration(milliseconds: 1000);

  // Updates counts and selection state optimistically
  void _updateFeedbackState(BlogFeedback? nextFeedback) {
    if (_currentFeedback == BlogFeedback.useful) {
      _usefulCount -= 1;
    } else if (_currentFeedback == BlogFeedback.notUseful) {
      _notUsefulCount -= 1;
    }

    if (nextFeedback == BlogFeedback.useful) {
      _usefulCount += 1;
    } else if (nextFeedback == BlogFeedback.notUseful) {
      _notUsefulCount += 1;
    }

    _currentFeedback = nextFeedback;
  }

  @override
  void onDebounced(BlogFeedback? value) {
    // If the debounced target is identical to the last successfully saved state, skip API call
    if (_lastSavedFeedback == value) return;
    if (AppSession.isAuthenticated) {
      context.read<BlogFeedbackCubit>().addFeedback(
        blogId: widget.blog.id,
        feedback: value,
      );
    }
  }

  Widget _feedbackChip(BuildContext context, BlogFeedback feedback) {
    final isSelected = _currentFeedback == feedback;
    final icon = switch ((feedback, isSelected)) {
      (BlogFeedback.useful, true) => AppIcons.thumbsUpFill,
      (BlogFeedback.useful, false) => AppIcons.thumbsUp,
      (BlogFeedback.notUseful, true) => AppIcons.thumbsDownFill,
      (BlogFeedback.notUseful, false) => AppIcons.thumbsDown,
    };

    final count = switch (feedback) {
      BlogFeedback.useful => _usefulCount,
      BlogFeedback.notUseful => _notUsefulCount,
    };

    return AppButton(
      variant: AppButtonVariant.text,
      width: AppButtonWidth.content,
      size: AppButtonSize.compact,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      backgroundColor: context.colorScheme.surface,
      foregroundColor: context.colorScheme.onSurface,
      onPressed: () {
        final nextFeedback = _currentFeedback == feedback ? null : feedback;
        setState(() {
          _updateFeedbackState(nextFeedback);
        });
        debounce(nextFeedback);
      },
      icon: Icon(icon, color: context.colorScheme.onSurface),
      child: Text(count.compact),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BlogFeedbackCubit, BlogFeedbackState>(
      listener: (context, state) {
        if (state is BlogFeedbackSuccess) {
          // Update the saved feedback baseline upon a successful API call
          _lastSavedFeedback = state.feedback;
        } else if (state is BlogFeedbackFailure) {
          // Revert optimistic updates and restore to the last successfully saved feedback on failure
          setState(() {
            _updateFeedbackState(_lastSavedFeedback);
          });
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            spacing: 10,
            children: [
              Expanded(
                child: Text(
                  'isThisBlogUseful'.translate(context),
                  style: context.labelLarge,
                ),
              ),
              _feedbackChip(context, BlogFeedback.useful),
              _feedbackChip(context, BlogFeedback.notUseful),
            ],
          ),
        ),
      ),
    );
  }
}
