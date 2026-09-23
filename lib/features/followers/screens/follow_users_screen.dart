import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/features/followers/cubits/follow_cubit.dart';
import 'package:eClassify/features/followers/cubits/follow_user_list_cubit.dart';
import 'package:eClassify/features/followers/screens/follow_user_list.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowUsersScreen extends StatefulWidget {
  const FollowUsersScreen({
    required this.title,
    this.defaultSelectedTab = 0,
    this.userId,
    super.key,
  }) : assert(
         defaultSelectedTab >= 0 && defaultSelectedTab < 2,
         'The index must be either 0 or 1',
       );

  final String title;
  final int defaultSelectedTab;
  final int? userId;

  @override
  State<FollowUsersScreen> createState() => _FollowUsersScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments! as Map<String, dynamic>;
    final userId = args['user_id'] as int?;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => MultiBlocProvider(
        providers: [
          if (userId != null) ...[
            BlocProvider(create: (_) => FollowersListCubit(userId)),
            BlocProvider(create: (_) => FollowingListCubit(userId)),
          ],
          if (userId == null) BlocProvider(create: (_) => FollowCubit()),
        ],
        child: FollowUsersScreen(
          userId: args['user_id'] as int?,
          title: args['title'] as String,
          defaultSelectedTab: args['default_tab'] as int? ?? 0,
        ),
      ),
    );
  }
}

class _FollowUsersScreenState extends State<FollowUsersScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = TabController(
    initialIndex: widget.defaultSelectedTab,
    length: 2,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    context.read<FollowersListCubit>().getUsers();
    context.read<FollowingListCubit>().getUsers();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // HeroMode is disabled because both tabs can contain the same user.
    // Since the Hero tag is based on user.id, duplicate Hero tags may exist
    // in the widget tree simultaneously, causing navigation assertions.
    return HeroMode(
      enabled: false,
      child: AppScaffold(
        appBar: AppBar(
          title: Text(widget.title.translate(context)),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: TabBar(
              controller: _controller,
              tabs: [
                BlocSelector<FollowersListCubit, FollowUsersListState, int>(
                  selector: (state) {
                    return state is FollowUsersListSuccess
                        ? state.totalCount
                        : 0;
                  },
                  builder: (context, count) {
                    return Tab(
                      text:
                          '${'followers'.translate(context)} ${count > 0 ? '($count)' : ''}',
                    );
                  },
                ),
                BlocSelector<FollowingListCubit, FollowUsersListState, int>(
                  selector: (state) {
                    return state is FollowUsersListSuccess
                        ? state.totalCount
                        : 0;
                  },
                  builder: (context, count) {
                    return Tab(
                      text:
                          '${'following'.translate(context)} ${count > 0 ? '($count)' : ''}',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: Constant.pagePadding.copyWith(top: 20),
          child: TabBarView(
            controller: _controller,
            children: [
              FollowUsersList<FollowersListCubit>(showUnfollowButton: false),
              FollowUsersList<FollowingListCubit>(
                showUnfollowButton: widget.userId == null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
