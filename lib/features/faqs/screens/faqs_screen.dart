import 'package:eClassify/features/faqs/cubits/fetch_faqs_cubit.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/widgets/ads/interstitial_ad_on_exit_mixin.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return BlocProvider(
          create: (_) => FetchFaqsCubit(),
          child: const FaqsScreen(),
        );
      },
    );
  }

  @override
  State<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends State<FaqsScreen>
    with InterstitialAdOnExitMixin {
  int _expandedItem = -1;

  @override
  void initState() {
    super.initState();
    context.read<FetchFaqsCubit>().fetchFaqs();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: context.colorScheme.primary,
      onRefresh: () async {
        context.read<FetchFaqsCubit>().fetchFaqs();
      },
      child: AppScaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(title: Text("faqs".translate(context))),
        body: BlocBuilder<FetchFaqsCubit, FetchFaqsState>(
          builder: (context, state) {
            if (state is FetchFaqsInProgress) {
              return buildFaqsShimmer();
            }
            if (state is FetchFaqsFailure) {
              return QErrorWidget(
                error: state.error,
                onRetry: () {
                  context.read<FetchFaqsCubit>().fetchFaqs();
                },
              );
            }
            if (state is FetchFaqsSuccess) {
              if (state.faqModel.isEmpty) {
                return const QErrorWidget.emptyData();
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsetsDirectional.only(top: 7, start: 15, end: 15),
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  );
                },
                itemCount: state.faqModel.length,
                itemBuilder: (context, index) {
                  final faq = state.faqModel[index];
                  return ExpansionPanelList(
                    children: [
                      ExpansionPanel(
                        isExpanded: _expandedItem == index,
                        backgroundColor: context.colorScheme.secondary,
                        body: ListTile(title: Text(faq.answer.localized)),
                        headerBuilder: (context, isExpanded) {
                          return ListTile(
                            title: Text(
                              faq.question.localized,
                              style: context.bodyMedium.bold,
                            ),
                          );
                        },
                        canTapOnHeader: true,
                      ),
                    ],
                    elevation: 0.0,
                    animationDuration: const Duration(milliseconds: 700),
                    expansionCallback: (int item, bool status) {
                      if (status) {
                        _expandedItem = index;
                      } else {
                        _expandedItem = -1;
                      }
                      setState(() {});
                    },
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget buildFaqsShimmer() {
    return ListView.builder(
      itemCount: 7,
      shrinkWrap: true,
      padding: EdgeInsets.only(top: 7),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
          child: CustomShimmer(
            borderRadius: 0,
            width: double.infinity,
            height: 60,
          ),
        );
      },
    );
  }
}
