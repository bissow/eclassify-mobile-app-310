import 'package:eClassify/features/banner/cubits/banner_ad_cubit.dart';
import 'package:eClassify/features/banner/models/banner_ad.dart';
import 'package:eClassify/features/banner/screens/banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DetailBannerAdWidget extends StatelessWidget {
  const DetailBannerAdWidget({
    required this.section,
    required this.placement,
    super.key,
  });

  final DetailSection section;
  final BannerPlacement placement;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailBannerAdCubit, BannerAdState>(
      builder: (context, state) {
        final banner = context
            .read<DetailBannerAdCubit>()
            .bannersByKey[(section, placement)];
        if (banner == null) return const SizedBox.shrink();
        return BannerWidget(bannerAd: banner);
      },
    );
  }
}
