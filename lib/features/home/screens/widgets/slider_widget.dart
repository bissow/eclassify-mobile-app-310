import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/build_context_extensions.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/features/home/cubits/slider_cubit.dart';
import 'package:eClassify/features/home/models/home_slider.dart';
import 'package:eClassify/features/item/models/item_metadata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  final _controller = PageController();
  Timer? _timer;
  int _totalPage = 0;

  @override
  void dispose() {
    _clearTimer();
    _controller.dispose();
    super.dispose();
  }

  void _clearTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _clearTimer();
    if (_totalPage > 0) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) => _nextPage());
    }
  }

  void _nextPage() {
    // The timer can outlive the PageView it's driving — e.g. a slider
    // refresh swaps the built PageView out for a loading/error placeholder
    // without cancelling the timer. PageController.page asserts if accessed
    // while no PageView is attached, so bail out instead of crashing.
    if (!_controller.hasClients) return;
    final currentPage = _controller.page?.toInt() ?? 0;
    final nextPage = currentPage + 1;
    if (nextPage < _totalPage) {
      _controller.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _controller.animateToPage(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SliderCubit, SliderState>(
      listener: (context, state) {
        if (state is SliderSuccess && state.sliders.length > 1) {
          _totalPage = state.sliders.length;
          _startTimer();
        } else {
          _totalPage = 0;
          _clearTimer();
        }
      },
      builder: (context, state) {
        if (state is SliderLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 5.0,
              horizontal: Constant.horizontalPadding,
            ),
            child: AspectRatio(aspectRatio: 2, child: const CustomShimmer()),
          );
        }
        if (state is SliderFailure) {
          return const SizedBox.shrink();
        }
        if (state is SliderSuccess) {
          if (state.sliders.isEmpty) {
            return const SizedBox.shrink();
          }

          final imageSize = context.sizeFromAspectRatio(2);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: AspectRatio(
              aspectRatio: 2,
              child: PageView.builder(
                controller: _controller,
                itemCount: state.sliders.length,
                itemBuilder: (context, index) {
                  final slider = state.sliders[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constant.horizontalPadding,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _SliderTapHandler.handle(context, slider);
                      },
                      child: RepaintBoundary(
                        child: CustomImage(
                          src: slider.image,
                          fit: BoxFit.fill,
                          size: imageSize,
                          radius: 18,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _SliderTapHandler {
  static void handle(BuildContext context, HomeSlider slider) async {
    switch (slider) {
      case final CategorySlider s:
        _categorySliderHandler(context, s);
      case final ItemSlider s:
        _itemSliderHandler(context, s);
      case final ExternalLinkSlider s:
        _externalLinkHandler(context, s);
      default:
        throw UnsupportedError('Unsupported slider type');
    }
    ;
  }

  static void _categorySliderHandler(
    BuildContext context,
    CategorySlider slider,
  ) {
    final category = slider.category;
    if (category.hasSubCategories) {
      Navigator.of(
        context,
      ).pushNamed(Routes.categoryBrowsing, arguments: category);
    } else {
      Navigator.of(context).pushNamed(
        Routes.itemsList,
        arguments: CategoryMetaData(category: category),
      );
    }
  }

  static void _itemSliderHandler(BuildContext context, ItemSlider slider) {
    Navigator.of(
      context,
    ).pushNamed(Routes.adDetailsScreen, arguments: {'item_id': slider.itemId});
  }

  static void _externalLinkHandler(
    BuildContext context,
    ExternalLinkSlider slider,
  ) async {
    final canLaunch = await canLaunchUrl(slider.url);
    if (canLaunch) {
      launchUrl(slider.url);
    }
  }
}
