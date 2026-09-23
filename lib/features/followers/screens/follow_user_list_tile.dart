import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/followers/cubits/follow_cubit.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUserListTile extends StatefulWidget {
  const FollowUserListTile({
    required this.followUser,
    this.showUnfollowButton = false,
    super.key,
  });

  final UserPreview followUser;
  final bool showUnfollowButton;

  @override
  State<FollowUserListTile> createState() => _FollowUserListTileState();
}

class _FollowUserListTileState extends State<FollowUserListTile> {
  late bool isFollowing = true;

  Widget _getTrailingWidget() {
    return switch (widget.showUnfollowButton) {
      true => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 100, minWidth: 60, maxHeight: 32),
        child: BlocConsumer<FollowCubit, FollowState>(
          listenWhen: (prev, curr) =>
              curr.userId == widget.followUser.id && !curr.isLoading,
          listener: (context, state) {
            isFollowing = state.isFollowing;
            if (state.isFollowing) {
              context.read<FollowingListCubit>().increaseTotalCount();
            } else {
              context.read<FollowingListCubit>().decreaseTotalCount();
            }
          },
          buildWhen: (prev, curr) => curr.userId == widget.followUser.id,
          builder: (context, state) {
            var child = switch (state.isLoading) {
              true => Center(
                child: LoadingIndicator.inlineDots(
                  color: isFollowing ? Colors.red : context.colorScheme.primary,
                  dimension: 20,
                ),
              ),
              false => Text(
                isFollowing
                    ? 'unfollow'.translate(context)
                    : 'follow'.translate(context),
              ),
            };
            return AppButton(
              variant: AppButtonVariant.outlined,
              size: AppButtonSize.compact,
              width: AppButtonWidth.content,
              foregroundColor: isFollowing ? Colors.red : null,
              style: ButtonStyle(
                minimumSize: const WidgetStatePropertyAll(Size(100, 32)),
                maximumSize: const WidgetStatePropertyAll(Size(150, 32)),
              ),
              onPressed: () {
                if (isFollowing) {
                  context.read<FollowCubit>().unFollowSeller(
                    userId: widget.followUser.id,
                  );
                } else {
                  context.read<FollowCubit>().followSeller(
                    userId: widget.followUser.id,
                  );
                }
              },
              child: child,
            );
          },
        ),
      ),
      false => ConstrainedBox(
        constraints: BoxConstraints.tight(Size.square(30)),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(child: Icon(AppIcons.caretRight, size: 20)),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          Routes.sellerProfileScreen,
          arguments: {'seller_id': widget.followUser.id},
        );
      },
      leading: ProfileAvatar(
        src: widget.followUser.profile ?? '',
        size: Size.square(48),
        tag: widget.followUser.id.toString(),
        errorImage: UserPlaceholderImage(
          size: Size.square(48),
          placeholder: widget.followUser.placeholder,
        ),
      ),
      title: Text(widget.followUser.name),
      trailing: _getTrailingWidget(),
    );
  }
}
