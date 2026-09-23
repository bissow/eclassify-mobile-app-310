import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/chat/cubits/chat_list_cubit.dart';
import 'package:eClassify/features/chat/cubits/delete_chat_cubit.dart';
import 'package:eClassify/features/chat/cubits/seller_item_offers_cubit.dart';
import 'package:eClassify/features/chat/screens/inbox/widgets/buying_chat_list.dart';
import 'package:eClassify/features/chat/screens/inbox/widgets/chat_delete_confirmation_dialog.dart';
import 'package:eClassify/features/chat/screens/inbox/widgets/chat_search_bar.dart';
import 'package:eClassify/features/chat/screens/inbox/widgets/seller_item_offer_list.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/number_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => false;

  late TabController _tabController = TabController(length: 2, vsync: this);
  final SetNotifier<int> _selectedChats = SetNotifier<int>({});
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
    _tabController.addListener(_tabListener);
  }

  void _tabListener() {
    if (_tabController.indexIsChanging) return;
    if (_searchQuery.isNotNullAndNotEmpty) {
      _triggerSearch();
    }
  }

  void _triggerSearch() {
    if (_tabController.index == 0) {
      context.read<SellerItemOffersCubit>().getOffers(search: _searchQuery);
    } else {
      context.read<BuyingChatListCubit>().getChatUsers(search: _searchQuery);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_tabListener);
    _tabController.dispose();
    _selectedChats.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocProvider(
      create: (context) => DeleteChatCubit(),
      child: Builder(
        builder: (context) {
          return AppScaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: Text('chats'.translate(context)),
              bottom: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(child: _SellerOffersTabLabel()),
                  Tab(child: _BuyingChatTabLabel()),
                ],
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, Routes.blockedUserListScreen);
                  },
                  icon: Icon(AppIcons.prohibit, size: 20),
                ),
                ListenableBuilder(
                  listenable: Listenable.merge([
                    _selectedChats,
                    _tabController,
                  ]),
                  builder: (context, child) {
                    if (_selectedChats.isEmpty || _tabController.index == 0) {
                      return const SizedBox.shrink();
                    } else {
                      return child!;
                    }
                  },
                  child: IconButton(
                    onPressed: () async {
                      final shouldDelete =
                          await ChatDeleteConfirmationDialog.show(context) ??
                          false;
                      if (shouldDelete) {
                        final ids = _selectedChats.value.toList();
                        context.read<BuyingChatListCubit>().removeChatsLocally(
                          ids,
                        );
                        context.read<DeleteChatCubit>().deleteChats(
                          itemOfferIds: ids,
                        );
                        _selectedChats.clear();
                      }
                    },
                    icon: Icon(AppIcons.trash),
                  ),
                ),
              ],
            ),
            body: BlocListener<DeleteChatCubit, DeleteChatState>(
              listener: (context, state) {
                if (state is DeleteChatFailure) {
                  context.read<BuyingChatListCubit>().rollbackDeletion();
                  HelperUtils.showSnackBarMessage(context, state.error);
                }
                if (state is DeleteChatSuccess) {
                  context.read<BuyingChatListCubit>().commitDeletion();
                }
              },
              child: Padding(
                padding: Constant.pagePadding.copyWith(top: Constant.verticalPadding),
                child: Column(
                  spacing: 20,
                  children: [
                    ChatSearchBar(
                      onSearch: (value) {
                        _searchQuery = value;
                        _triggerSearch();
                      },
                      onClear: () {
                        _searchQuery = null;
                        context.read<SellerItemOffersCubit>().getOffers(
                          search: null,
                        );
                        context.read<BuyingChatListCubit>().getChatUsers(
                          search: null,
                        );
                      },
                    ),
                    Flexible(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          const SellerItemOfferList(),
                          BuyingChatList(selectedChats: _selectedChats),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tab label with an unread-count dot. Pulled out of [ChatListScreen]
/// because a `BlocSelector` inline as a `Tab.child` makes the tab list
/// unreadable — one line per tab is the point of that list.
class _TabLabelWithBadge extends StatelessWidget {
  const _TabLabelWithBadge({required this.label, required this.unreadCount});

  final String label;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    if (unreadCount <= 0) return text;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        text,
        Badge(
          backgroundColor: context.colorScheme.primary,
          label: Text('${unreadCount.compact}'),
        ),
      ],
    );
  }
}

class _SellerOffersTabLabel extends StatelessWidget {
  const _SellerOffersTabLabel();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<SellerItemOffersCubit, SellerItemOffersState, int>(
      selector: (state) => switch (state) {
        final SellerItemOffersSuccess s when s.offers.isNotEmpty =>
          s.offers.fold(0, (value, ele) => value + ele.unreadCount),
        _ => 0,
      },
      builder: (context, unreadCount) => _TabLabelWithBadge(
        label: 'selling'.translate(context),
        unreadCount: unreadCount,
      ),
    );
  }
}

class _BuyingChatTabLabel extends StatelessWidget {
  const _BuyingChatTabLabel();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BuyingChatListCubit, ChatListState, int>(
      selector: (state) => switch (state) {
        final ChatListSuccess b when b.users.isNotEmpty => b.users.fold(
          0,
          (value, ele) => value + ele.unreadCount,
        ),
        _ => 0,
      },
      builder: (context, unreadCount) => _TabLabelWithBadge(
        label: 'buying'.translate(context),
        unreadCount: unreadCount,
      ),
    );
  }
}
