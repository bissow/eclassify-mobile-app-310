import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/followers/cubits/follow_cubit.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/review/models/review_summary.dart';
import 'package:eClassify/features/seller/models/seller.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersWidget extends StatelessWidget {
  const FollowUsersWidget({required this.seller, super.key});

  final Seller seller;

  @override
  Widget build(BuildContext context) {
    final ref = context.watch<SellerReviewsCubit>();
    final seller = switch (ref.state) {
      DataState(result: final data) =>
        data.metadataAs<SellerReviewSummary>().seller,
      _ => this.seller,
    };

    return Theme(
      data: ThemeData(
        chipTheme: ChipThemeData(
          backgroundColor: context.colorScheme.surface,
          labelStyle: context.labelMedium,
          side: BorderSide.none,
          shape: StadiumBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: context.colorScheme.primary,
            foregroundColor: context.colorScheme.onPrimary,
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'user_id': seller.id,
                  'title': seller.name,
                  'default_tab': 0,
                },
              );
            },
            child: Chip(
              label: Text(
                '${seller.followers} ${'followers'.translate(context)}',
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'user_id': seller.id,
                  'title': seller.name,
                  'default_tab': 1,
                },
              );
            },
            child: Chip(
              label: Text(
                '${seller.following} ${'following'.translate(context)}',
              ),
            ),
          ),
          if (AppSession.isAuthenticated)
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: 100),
              child: BlocConsumer<FollowCubit, FollowState>(
                listenWhen: (prev, curr) =>
                    prev.isLoading &&
                    !curr.isLoading &&
                    prev.isFollowing != curr.isFollowing,
                listener: (context, state) {
                  context.read<SellerReviewsCubit>().updateSellerFollowerCount(
                    isFollowing: state.isFollowing,
                  );
                  if (state.isFollowing) {
                    context.read<FollowingListCubit>().increaseTotalCount();
                  } else {
                    context.read<FollowingListCubit>().decreaseTotalCount();
                  }
                },
                builder: (context, followState) {
                  final textWidget = switch ((
                    followState.isFollowing,
                    followState.isLoading,
                  )) {
                    (_, true) => LoadingIndicator.inlineDots(dimension: 20),
                    (false, false) => Text('follow'.translate(context)),
                    (true, false) => Text('unfollow'.translate(context)),
                  };

                  final iconWidget = switch ((
                    followState.isFollowing,
                    followState.isLoading,
                  )) {
                    (_, true) => null,
                    (false, false) => const Icon(AppIcons.plus),
                    (true, false) => const Icon(AppIcons.check),
                  };

                  return FilledButton.icon(
                    onPressed: () {
                      if (followState.isLoading) return;
                      if (followState.isFollowing) {
                        context.read<FollowCubit>().unFollowSeller(
                          userId: seller.id,
                        );
                      } else {
                        context.read<FollowCubit>().followSeller(
                          userId: seller.id,
                        );
                      }
                    },
                    label: textWidget,
                    icon: iconWidget,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
