import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_overlay.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/core/widgets/feedback/shimmer_loading_container.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/features/chat/cubits/blocked_users_list_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_list_cubit.dart';
import 'package:eClassify/features/chat/cubits/user_block_cubit.dart';
import 'package:eClassify/features/chat/screens/widgets/modals/block_user_dialog.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BlockedUserListScreen extends StatefulWidget {
  const BlockedUserListScreen({super.key});

  static Route route(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => BlockedUserListCubit()),
            BlocProvider(create: (context) => UserBlockCubit()),
          ],
          child: const BlockedUserListScreen(),
        );
      },
    );
  }

  @override
  State<BlockedUserListScreen> createState() => _BlockedUserListScreenState();
}

class _BlockedUserListScreenState extends State<BlockedUserListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BlockedUserListCubit>().getBlockedUsers();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text('blockedUsers'.translate(context))),
      body: BlocListener<UserBlockCubit, UserBlockState>(
        listener: (context, state) {
          if (state is UserBlockLoading) {
            LoadingOverlay.show(context);
          }
          if (state is UserBlockFailure) {
            LoadingOverlay.hide();
            HelperUtils.showSnackBarMessage(context, state.message);
          }
          if (state is UserBlockSuccess) {
            LoadingOverlay.hide();
            context.read<BlockedUserListCubit>().removeUser(state.userId);
            context.read<BuyingChatListCubit>().toggleBlockStatus(
              userId: state.userId,
              isUserBlocked: state.isBlocked,
            );
            HelperUtils.showSnackBarMessage(
              context,
              "userUnblockedSuccessfully".translate(context),
            );
          }
        },
        child: Padding(
          padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
          child: BlocBuilder<BlockedUserListCubit, BlockedUserListState>(
            builder: (context, state) {
              if (state is BlockedUserListLoading) {
                return Column(
                  spacing: 10,
                  children: List.generate(
                    5,
                    (index) => CustomShimmer(height: 50),
                  ),
                );
              }

              if (state is BlockedUserListFailure) {
                return QErrorWidget(
                  error: state.error,
                  onRetry: () {
                    context.read<BlockedUserListCubit>().getBlockedUsers();
                  },
                );
              }

              if (state is BlockedUserListSuccess) {
                if (state.users.isEmpty) {
                  return QErrorWidget.emptyData(
                    onRetry: () {
                      context.read<BlockedUserListCubit>().getBlockedUsers();
                    },
                  );
                }

                return ListView.separated(
                  itemCount: state.users.length,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemBuilder: (context, index) {
                    final user = state.users[index];

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      onTap: () async {
                        final shouldProceed =
                            await BlockUserDialog.show(
                              context,
                              user: user,
                              isUserBlocked: true,
                            ) ??
                            false;
                        if (shouldProceed) {
                          context.read<UserBlockCubit>().toggleBlockUser(
                            userId: user.id,
                            isUserBlocked: true,
                          );
                        }
                      },
                      leading: ProfileAvatar(
                        src: user.profile ?? '',
                        size: Size.square(40),
                        tag: user.id.toString(),
                        errorImage: UserPlaceholderImage(
                          size: Size.square(40),
                          placeholder: user.placeholder,
                        ),
                      ),
                      title: Text(user.name, style: context.titleMedium),
                    );
                  },
                  separatorBuilder: (context, index) => 10.vGap,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
