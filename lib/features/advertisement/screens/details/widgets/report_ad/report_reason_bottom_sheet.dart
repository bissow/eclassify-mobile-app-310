import 'dart:io';

import 'package:eClassify/features/advertisement/cubits/item_report_cubit.dart';
import 'package:eClassify/features/advertisement/cubits/report_reason_cubit.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

abstract class ReportReasonBottomSheet {
  static void show(BuildContext context, {required int itemId}) {
    UiUtils.showBottomSheet(
      context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ItemReportCubit>()),
          BlocProvider(create: (_) => ReportReasonCubit()),
        ],
        child: SafeArea(
          bottom: Platform.isAndroid,
          child: _ReasonsList(itemId: itemId),
        ),
      ),
    );
  }
}

class _ReasonsList extends StatefulWidget {
  const _ReasonsList({required this.itemId});

  final int itemId;

  @override
  State<_ReasonsList> createState() => _ReasonsListState();
}

class _ReasonsListState extends State<_ReasonsList>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final ValueNotifier<int?> _selected = ValueNotifier(-1);
  late final _sizeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _selected.dispose();
    super.dispose();
  }

  Widget _listTile(String title, int? reasonId) {
    return ValueListenableBuilder(
      valueListenable: _selected,
      builder: (context, value, child) {
        return ListTile(
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          onTap: () async {
            setState(() {
              _selected.value = reasonId;
            });
            if (reasonId == null) {
              _sizeController.forward();
              await Future.delayed(const Duration(milliseconds: 300));
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            } else {
              if (_sizeController.isCompleted) {
                _sizeController.reverse();
              }
            }
          },
          selected: value == reasonId,
          selectedColor: context.colorScheme.secondary,
          selectedTileColor: context.colorScheme.primary,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: context.mutedColor),
            borderRadius: BorderRadius.circular(8),
          ),
          title: Text(title),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportReasonCubit, ReportReasonState>(
      builder: (context, state) {
        if (state is ReportReasonInitial) {
          context.read<ReportReasonCubit>().getReasons();
        }
        if (state is ReportReasonFailure) {
          HelperUtils.showSnackBarMessage(context, state.errorMessage);
          Navigator.of(context).pop();
        }
        if (state is ReportReasonSuccess) {
          return Padding(
            padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  Text(
                    'reportItem'.translate(context),
                    style: context.titleLarge.bold,
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: ListView.separated(
                        controller: _scrollController,
                        itemCount: state.reasons.length + 1,
                        itemBuilder: (context, index) {
                          if (index == state.reasons.length) {
                            return Column(
                              children: [
                                _listTile('other'.translate(context), null),
                                SizeTransition(
                                  sizeFactor: _sizeController,
                                  axis: Axis.vertical,
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 5.0),
                                    child: TextField(
                                      controller: _controller,
                                      maxLines: null,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: context.colorScheme.primary,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        hintText: 'writeReasonHere'.translate(
                                          context,
                                        ),
                                        constraints: BoxConstraints(
                                          maxHeight: 100,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            final reason = state.reasons[index];
                            return _listTile(
                              reason.reason.localized,
                              reason.id,
                            );
                          }
                        },
                        separatorBuilder: (_, _) => 5.vGap,
                      ),
                    ),
                  ),
                  AppButton(
                    variant: AppButtonVariant.filled,
                    size: AppButtonSize.small,
                    onPressed: () {
                      context.read<ItemReportCubit>().report(
                        itemId: widget.itemId,
                        reasonId: _selected.value,
                        message: _controller.text.trim(),
                      );
                    },
                    child: BlocConsumer<ItemReportCubit, ItemReportState>(
                      listener: (context, state) {
                        if (state is ItemReportSuccess) {
                          Navigator.of(context).pop();
                        }
                        if (state is ItemReportFailure) {
                          Navigator.of(context).pop();
                        }
                      },
                      builder: (context, state) {
                        return state is ItemReportLoading
                            ? LoadingIndicator.inlineDots()
                            : Text('submit'.translate(context));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: CustomShimmer.baseColor(context),
                  highlightColor: CustomShimmer.highlightColor(context),
                  child: SizedBox(
                    height: 50,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.all(color: context.mutedColor),
                      ),
                    ),
                  ),
                );
              },
              itemCount: 5,
            ),
          ),
        );
      },
    );
  }
}
