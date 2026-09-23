import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersCountWidget extends StatelessWidget {
  const FollowUsersCountWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final followersCount = context.select<FollowersListCubit, int>(
      (cubit) => switch (cubit.state) {
        final FollowUsersListSuccess s => s.totalCount,
        _ => 0,
      },
    );

    final followingCount = context.select<FollowingListCubit, int>(
      (cubit) => switch (cubit.state) {
        final FollowUsersListSuccess s => s.totalCount,
        _ => 0,
      },
    );

    return Row(
      spacing: 8,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'title': 'followers'.translate(context),
                  'default_tab': 0,
                },
              );
            },
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: context.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    '${followersCount.compact} ${'followers'.translate(context)}',
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(
                Routes.followersScreen,
                arguments: {
                  'title': 'followers'.translate(context),
                  'default_tab': 1,
                },
              );
            },
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: context.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Center(
                  child: Text(
                    '${followingCount.compact} ${'following'.translate(context)}',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
