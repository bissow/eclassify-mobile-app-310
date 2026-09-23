import 'package:eClassify/features/seller/extensions/seller_preview_extension.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/followers/cubits/follow_cubit.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/features/seller/models/seller.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReelUserCard extends StatelessWidget {
  const ReelUserCard({required this.user, super.key});

  final Seller user;

  @override
  Widget build(BuildContext context) {
    final isMyUser =
        AppSession.currentUser?.id.toString() == user.id.toString();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.sellerProfileScreen,
          arguments: {'seller_id': user.id},
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 16,
            child: CustomImage(
              src: user.profile,
              size: Size.square(32),
              radius: 32,
            ),
          ),
          12.hGap,
          Flexible(
            child: Text(
              user.name,
              maxLines: 1,
              style: context.titleMedium.withColor(Colors.white),
            ),
          ),
          if (user.isVerified) ...[
            4.hGap,
            Icon(
              AppIcons.sealCheckFill,
              size: 16,
              color: context.colorScheme.tertiary,
            ),
          ],
          if (AppSession.isAuthenticated && !isMyUser) ...[
            8.hGap,
            BlocProvider(
              create: (_) => FollowCubit(),
              child: _FollowButton(user: user),
            ),
          ],
        ],
      ),
    );
  }
}

class _FollowButton extends StatefulWidget {
  const _FollowButton({required this.user});

  final Seller user;

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  late bool isFollowing = widget.user.isFollowing;
  late bool isMyUser =
      AppSession.currentUser?.id.toString() == widget.user.id.toString();

  @override
  void initState() {
    super.initState();
    // Add user if not already present in the list to consistently sync the follow
    // state across all the reels without refreshing
    final wasUserRemoved = context.read<FollowingListCubit>().removedUsers.any(
      (id) => id == widget.user.id,
    );
    if (isFollowing && !wasUserRemoved) {
      context.read<FollowingListCubit>().addUser(
        widget.user.toPreview(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.watch<FollowCubit>();
    isFollowing = context.select<FollowingListCubit, bool>(
      (cubit) => switch (cubit.state) {
        FollowUsersListSuccess(:final users) => users.any(
          (u) => u.id == widget.user.id,
        ),
        _ => false,
      },
    );

    return BlocBuilder<FollowCubit, FollowState>(
      builder: (context, state) {
        return AppButton(
          variant: AppButtonVariant.filled,
          width: AppButtonWidth.content,
          size: AppButtonSize.compact,
          style: ButtonStyle(visualDensity: VisualDensity.compact),
          shape: const StadiumBorder(),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          onPressed: () {
            if (isFollowing) {
              context.read<FollowCubit>().unFollowSeller(
                userId: widget.user.id,
              );
              context.read<FollowingListCubit>().removeUser(widget.user.id);
              isFollowing = false;
            } else {
              context.read<FollowCubit>().followSeller(userId: widget.user.id);
              context.read<FollowingListCubit>().addUser(
                widget.user.toPreview(),
              );
              isFollowing = true;
            }
          },
          title: isFollowing ? 'following' : 'follow',
        );
      },
    );
  }
}
