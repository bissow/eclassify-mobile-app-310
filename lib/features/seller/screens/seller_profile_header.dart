import 'package:eClassify/features/followers/cubits/follow_cubit.dart';
import 'package:eClassify/core/cubits/paginated_cubit.dart';
import 'package:eClassify/features/review/cubits/reviews_cubit.dart';
import 'package:eClassify/features/review/models/review.dart';
import 'package:eClassify/features/review/models/review_summary.dart';
import 'package:eClassify/features/seller/models/seller.dart';
import 'package:eClassify/features/seller/screens/follow_users_widget.dart';
import 'package:eClassify/features/seller/screens/seller_profile_tab_bar.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/date_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/deep_link/deep_link_target.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/share_utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SellerProfileHeaderDelegate extends SliverPersistentHeaderDelegate {
  const SellerProfileHeaderDelegate({
    required this.controller,
    required this.sellerId,
  });

  final TabController controller;
  final int sellerId;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => SellerProfileHeader(controller: controller, sellerId: sellerId);

  @override
  double get maxExtent => kToolbarHeight * 6;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class SellerProfileHeader extends StatelessWidget {
  const SellerProfileHeader({
    required this.controller,
    required this.sellerId,
    super.key,
  });

  final TabController controller;
  final int sellerId;

  @override
  Widget build(BuildContext context) {
    final expandedHeight = kToolbarHeight * 7;
    final collapsedHeight = kToolbarHeight;

    return SliverAppBar(
      actions: [
        IconButton(
          onPressed: () {
            ShareUtility.share(context, SellerDeepLink(sellerId));
          },
          icon: Icon(AppIcons.shareNetwork),
        ),
      ],
      pinned: true,
      expandedHeight: expandedHeight,
      collapsedHeight: collapsedHeight,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: SellerProfileTabBar(controller: controller),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 60),
          child:
              BlocSelector<
                SellerReviewsCubit,
                PaginatedState<SellerReview>,
                (Seller seller, int total)?
              >(
                selector: (state) => switch (state) {
                  DataState(:final result) => (
                    result.metadataAs<SellerReviewSummary>().seller,
                    result.total,
                  ),
                  _ => null,
                },
                builder: (context, data) {
                  if (data != null) {
                    // Unlike a BlocListener, this builder runs synchronously
                    // with whatever the *current* state already is — needed
                    // because SellerProfileScreen.route() can be handed an
                    // already-loaded SellerReviewsCubit (e.g. navigating
                    // here from the ad details seller card) to skip a
                    // refetch. In that case no new state ever gets emitted
                    // for a listener to react to, so FollowCubit would
                    // never be seeded otherwise. Post-frame since emitting
                    // straight from build is best avoided.
                    //
                    // userId stays null until the user's own first
                    // follow/unfollow call — gate on that so a stale rebuild
                    // here (e.g. SellerReviewsCubit re-emitting for an
                    // unrelated reason) can never stomp back over a toggle
                    // the user already made.
                    final followCubit = context.read<FollowCubit>();
                    final sellerFollowing = data.$1.isFollowing;
                    if (followCubit.state.userId == null &&
                        followCubit.state.isFollowing != sellerFollowing) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        followCubit.setFollowingStatus(sellerFollowing);
                      });
                    }
                  }
                  if (data == null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 4,
                      children: [
                        CustomShimmer(height: 80, width: 80, borderRadius: 40),
                        CustomShimmer(height: 20, width: 100),
                        CustomShimmer(height: 20, width: 150),
                      ],
                    );
                  }
                  final (seller, total) = data;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      ProfileAvatar(
                        src: seller.profile,
                        size: Size.square(80),
                        tag: seller.id.toString(),
                        errorImage: UserPlaceholderImage(
                          size: Size.square(80),
                          placeholder: seller.placeholder,
                        ),
                      ),
                      4.vGap,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          Text(seller.name, style: context.titleMedium.bold),
                          if (seller.isVerified)
                            Icon(
                              AppIcons.sealCheckFill,
                              color: context.colorScheme.tertiary,
                              size: 16,
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          Icon(
                            AppIcons.starFill,
                            color: Colors.amber,
                            size: 16,
                          ),
                          Text(
                            seller.averageRating.toStringAsFixed(1),
                            style: context.labelLarge,
                          ),

                          Text(
                            '($total  ${'ratings'.translate(context)})',
                            style: context.labelLarge,
                          ),
                        ],
                      ),
                      if (seller.showPersonalDetails &&
                          AppSession.isAuthenticated)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 4,
                          children: [
                            Flexible(
                              child: Text(
                                seller.email,
                                style: context.labelLarge,
                              ),
                            ),
                            if (seller.contact.isNotEmpty)
                              const SizedBox(
                                height: 15,
                                child: VerticalDivider(),
                              ),
                            if (seller.contact.isNotEmpty)
                              Flexible(
                                child: Text(
                                  HelperUtils.getFormattedNumber(
                                    seller.contact,
                                  ),
                                  style: context.labelLarge,
                                ),
                              ),
                          ],
                        ),
                      if (seller.joinedAt != null)
                        Text(
                          '${'memberSince'.translate(context)} ${seller.joinedAt!.format(formatString: 'MMMM yyyy')}',
                          style: context.labelMedium.withColor(
                            context.mutedColor,
                          ),
                        ),
                      4.vGap,
                      FollowUsersWidget(seller: seller),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }
}
