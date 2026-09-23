import 'dart:async';

import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/reels/cubits/fetch_reel_cubit.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/utils/background_upload_utility.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReelViewWidget extends StatefulWidget {
  const ReelViewWidget({
    required this.itemId,
    required this.isMyReel,
    super.key,
  });

  final int itemId;
  final bool isMyReel;

  @override
  State<ReelViewWidget> createState() => _ReelViewWidgetState();
}

class _ReelViewWidgetState extends State<ReelViewWidget> {
  StreamSubscription? _uploadSubscription;

  @override
  void dispose() {
    _uploadSubscription?.cancel();
    super.dispose();
  }

  /// `FetchReelFailure` here doesn't mean this video ad has no reel — every
  /// item that renders this widget is a video ad, so a reel is always
  /// expected. It's more likely the background upload from ad posting
  /// hasn't finished server-side yet. Listen for that specific upload to
  /// complete and retry, instead of leaving the reel looking missing until
  /// the user backs out and reopens the ad.
  void _listenForUploadCompletion(FetchReelCubit cubit) {
    if (_uploadSubscription != null) return;

    _uploadSubscription = BackgroundUploadUtility.listenForItemUploadCompletion(
      itemId: widget.itemId.toString(),
      onComplete: () {
        _uploadSubscription?.cancel();
        _uploadSubscription = null;
        if (mounted) {
          cubit.fetchReel(itemId: widget.itemId, isMyReel: widget.isMyReel);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FetchReelCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<FetchReelCubit, FetchReelState>(
            listenWhen: (_, state) => state is FetchReelFailure,
            listener: (context, state) {
              _listenForUploadCompletion(context.read<FetchReelCubit>());
            },
            builder: (context, state) {
              if (state is FetchReelInitial) {
                context.read<FetchReelCubit>().fetchReel(
                  itemId: widget.itemId,
                  isMyReel: widget.isMyReel,
                );
              }
              if (state is FetchReelSuccess) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.videoAdsScreen,
                      arguments: {
                        'reel_id': state.ad.id,
                        'show_current_user_reel': widget.isMyReel,
                      },
                    );
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox.fromSize(
                        size: Size.square(48),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black26,
                                BlendMode.srcOver,
                              ),
                              image: NetworkImage(state.ad.thumbnail),
                            ),
                          ),
                          child: Icon(AppIcons.playCircle, color: Colors.white),
                        ),
                      ),
                      PositionedDirectional(
                        end: 0,
                        start: 0,
                        bottom: -5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              'videoAd'.translate(context),
                              textAlign: TextAlign.center,
                              style: context.labelSmall.copyWith(
                                fontSize: 8,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (state is FetchReelFailure) {
                return const _ReelProcessingBadge();
              }
              return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

class _ReelProcessingBadge extends StatelessWidget {
  const _ReelProcessingBadge();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'videoProcessing'.translate(context),
      child: ClipOval(
        child: SizedBox.fromSize(
          size: Size.square(48),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const CustomShimmer(),
              Center(
                child: Icon(AppIcons.playCircle, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
