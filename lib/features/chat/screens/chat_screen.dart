import 'package:eClassify/app/session/app_session.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/scroll_extension.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/feedback/q_error_widget.dart';
import 'package:eClassify/features/advertisement/cubits/item_status_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_message_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_session_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_template_cubit.dart';
import 'package:eClassify/features/chat/cubits/delete_chat_cubit.dart';
import 'package:eClassify/features/chat/cubits/item_offer_cubit.dart';
import 'package:eClassify/features/chat/cubits/load_chat_cubit.dart';
import 'package:eClassify/features/chat/cubits/user_block_cubit.dart';
import 'package:eClassify/features/chat/models/chat.dart';
import 'package:eClassify/features/chat/models/chat_message.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_date_chip.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_listeners_scope.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_message_widget.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_message_widget_factory/offer_chat_message_widget.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_screen_app_bar.dart';
import 'package:eClassify/features/chat/screens/widgets/chat_shimmer_widget.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/message_composer.dart';
import 'package:eClassify/features/chat/screens/widgets/modals/block_user_dialog.dart';
import 'package:eClassify/features/chat/screens/widgets/modals/delete_messages_dialog.dart';
import 'package:eClassify/features/chat/screens/widgets/unread_messages_indicator.dart';
import 'package:eClassify/features/chat/services/chat_event_bus.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:eClassify/features/review/cubits/add_item_review_cubit.dart';
import 'package:eClassify/core/widgets/layout/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({this.chat, this.isSeller, this.id, super.key});

  final Chat? chat;

  // Determine whether the current user is seller or buyer
  final bool? isSeller;

  final int? id;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map<String, dynamic>;
    final chat = args['chat_user'] as Chat?;
    final id = args['id'] as int?;

    if (chat == null && id == null) {
      throw ArgumentError('Both chat and id cannot be null');
    }

    final myId = AppSession.currentUser!.id;
    ;
    final isSeller = chat != null ? chat.sellerId == myId : false;
    return MaterialPageRoute(
      settings: routeSettings,
      builder: (_) => ChatScreen(chat: chat, isSeller: isSeller, id: id),
    );
  }

  Widget buildChatContent(Chat chatVal) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ChatSessionCubit(chatVal, isCurrentUserSeller: isSeller ?? false),
        ),
        BlocProvider(create: (_) => ChatMessageCubit(chatVal.id)),
        BlocProvider(create: (_) => UserBlockCubit()),
        BlocProvider(create: (_) => AddItemReviewCubit()),
        BlocProvider(create: (_) => ItemStatusCubit()),
        BlocProvider(create: (_) => DeleteChatCubit()),
        BlocProvider(create: (_) => ChatTemplateCubit()),
        BlocProvider(create: (_) => ItemOfferCubit()),
      ],
      child: _ChatScreenContent(chat: chatVal, isSeller: isSeller ?? false),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (chat != null) {
      return buildChatContent(chat!);
    }

    return BlocProvider(
      create: (_) => LoadChatCubit()..loadChat(itemOfferId: id!),
      child: BlocBuilder<LoadChatCubit, LoadChatState>(
        builder: (context, state) {
          if (state is LoadChatInProgress) {
            return Material(child: Center(child: LoadingIndicator()));
          } else if (state is LoadChatFailure) {
            return Material(
              child: QErrorWidget(
                error: state.error,
                onRetry: () {
                  context.read<LoadChatCubit>().loadChat(itemOfferId: id!);
                },
              ),
            );
          } else if (state is LoadChatSuccess) {
            return buildChatContent(state.chat);
          }
          return Material(child: Center(child: LoadingIndicator()));
        },
      ),
    );
  }
}

class _ChatScreenContent extends StatefulWidget {
  const _ChatScreenContent({required this.chat, required this.isSeller});

  final Chat chat;
  final bool isSeller;

  @override
  State<_ChatScreenContent> createState() => _ChatScreenContentState();
}

class _ChatScreenContentState extends State<_ChatScreenContent>
    with RouteAware {
  late int myId = AppSession.currentUser!.id;
  late final SetNotifier<int> _selectionNotifier = SetNotifier({});
  int? _unreadMessageId;
  bool _hasCalculatedUnreadId = false;

  ChatMessageCubit get messageCubit => context.read<ChatMessageCubit>();

  UserPreview get receiver =>
      widget.isSeller ? widget.chat.buyer : widget.chat.seller;

  @override
  void initState() {
    super.initState();
    context.read<ChatMessageCubit>().getMessages();
    context.read<ItemStatusCubit>().getItemStatus(itemId: widget.chat.itemId);
    ChatEventBus.instance.emit(
      ChatReadEvent(widget.chat.id, itemId: widget.chat.itemId),
    );
    context.read<ChatTemplateCubit>().getChatTemplates(
      itemId: widget.chat.itemId,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Constant.routeObserver.subscribe(this, ModalRoute.of(context)!);
    // subscribe() only notifies future didPush/didPop events — it doesn't
    // replay the push that already happened for this route, so the initial
    // "this chat is active" state has to be set explicitly here too.
    AppSession.setActiveChatId(widget.chat.id);
  }

  @override
  void dispose() {
    _selectionNotifier.dispose();
    Constant.routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Called when this route has been pushed.
    AppSession.setActiveChatId(widget.chat.id);
    Log.debug('Pushed Chat Route');
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and this route shows up.
    AppSession.setActiveChatId(widget.chat.id);
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed, and this route is no longer visible.
    AppSession.setActiveChatId(null);
  }

  @override
  void didPop() {
    // Called when this route has been popped off.
    AppSession.setActiveChatId(null);
  }

  void _handleOnTap(ChatMessage message) {
    if (message is OfferChatMessage) return;
    if (_selectionNotifier.isNotEmpty) {
      if (message.id != null && message.senderId == myId) {
        _selectionNotifier.toggle(message.id!);
      }
    }
  }

  void _handleOnLongPress(ChatMessage message) {
    if (message is OfferChatMessage) return;
    if (_selectionNotifier.isEmpty) {
      if (message.id != null && message.senderId == myId) {
        _selectionNotifier.add(message.id!);
      }
    }
  }

  Future<void> _onDelete() async {
    final ids = _selectionNotifier.value.toList();
    final confirmed =
        await DeleteMessagesDialog.show(context, count: ids.length) ?? false;
    if (confirmed) {
      context.read<ChatMessageCubit>().deleteMessages(widget.chat.id, ids);
      _selectionNotifier.clear();
    }
  }

  bool _showTimeStamp(ChatMessage current, ChatMessage? previous) {
    if (previous == null) return true;
    final currentDateTime = current.dateTime;
    final previousDateTime = previous.dateTime;

    final isSameDay = DateUtils.isSameDay(currentDateTime, previousDateTime);
    final isSameTime =
        currentDateTime.hour == previousDateTime.hour &&
        currentDateTime.minute == previousDateTime.minute;

    return !isSameDay || !isSameTime;
  }

  @override
  Widget build(BuildContext context) {
    final bottomBar = _ChatBottomBar(receiver: receiver);

    // Same rule _ChatBottomBar uses to disable composing: offers make no
    // sense on a sold, expired, rejected or inactive item. `unknown` (status
    // not loaded yet / fetch failed) is treated as usable, as there.
    final isItemActive = context.select<ItemStatusCubit, bool>(
      (c) => switch (c.state) {
        ItemStatusSuccess(:final status) =>
          status == ItemStatus.approved || status == ItemStatus.unknown,
        _ => true,
      },
    );

    return ChatListenersScope(
      child: ListenableBuilder(
        listenable: _selectionNotifier,
        builder: (context, child) {
          return AppScaffold(
            appBar: ChatScreenAppBar(
              selectionNotifier: _selectionNotifier,
              onDelete: _onDelete,
              showOfferBar:
                  isItemActive &&
                  !widget.chat.item.isFree &&
                  !widget.chat.item.isJobItem,
              isSelectionMode: _selectionNotifier.isNotEmpty,
            ),
            bottomNavigationBar: bottomBar,
            body: child!,
          );
        },
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.isNearBottom && messageCubit.hasMore) {
              messageCubit.getMessages();
            }
            return false;
          },
          child: BlocConsumer<ChatMessageCubit, ChatMessageState>(
            listener: (context, state) {
              if (!_hasCalculatedUnreadId && state.messages.isNotEmpty) {
                if (widget.chat.unreadCount > 0) {
                  final targetIndex = widget.chat.unreadCount - 1;
                  if (targetIndex < state.messages.length) {
                    _unreadMessageId = state.messages[targetIndex].id;
                    _hasCalculatedUnreadId = true;
                  }
                } else {
                  _hasCalculatedUnreadId = true;
                }
              }
            },
            builder: (context, state) {
              if (state.isLoading && state.messages.isEmpty) {
                return SingleChildScrollView(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ChatShimmerWidget(seed: widget.chat.id),
                );
              }

              if (state.messages.isNotEmpty) {
                return ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  physics: const ClampingScrollPhysics(),
                  itemCount: state.messages.length + 1,
                  reverse: true,
                  itemBuilder: (context, index) {
                    if (index == state.messages.length) {
                      if (state.isLoading) {
                        return const ChatShimmerWidget(count: 4);
                      }
                      return const SizedBox.shrink();
                    }

                    final prevMessage = index > 0
                        ? state.messages[index - 1]
                        : null;
                    final message = state.messages[index];

                    if (message is OfferChatMessage) {
                      return OfferChatMessageWidget(
                        message: message,
                        username: receiver.name,
                      );
                    }

                    return ListenableBuilder(
                      listenable: _selectionNotifier,
                      builder: (context, _) {
                        return ChatMessageWidget(
                          key: ValueKey(message.localId ?? message.id),
                          message: message,
                          isMe: message.senderId == myId,
                          isSelected: _selectionNotifier.contains(
                            message.id ?? -1,
                          ),
                          showTime: _showTimeStamp(message, prevMessage),
                          onTap: () => _handleOnTap(message),
                          onLongPress: () => _handleOnLongPress(message),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    //The reason we check with index == (length - 1) is
                    //because separatorBuilder is always
                    //called in between the items
                    //Hence, it will always have one less index than the itemBuilder
                    if (index == state.messages.length - 1) {
                      final separator = ChatDateChip(
                        date: state.messages[index].dateTime,
                      );

                      if (state.messages[index].id != null &&
                          state.messages[index].id == _unreadMessageId) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const UnreadMessagesIndicator(),
                            separator,
                          ],
                        );
                      }
                      return separator;
                    }
                    final current = state.messages[index];
                    final previous = state.messages[index + 1];

                    Widget separator = const SizedBox.shrink();

                    if (!DateUtils.isSameDay(
                      current.dateTime,
                      previous.dateTime,
                    )) {
                      separator = ChatDateChip(date: current.dateTime);
                    }

                    if (current.id != null && current.id == _unreadMessageId) {
                      return const UnreadMessagesIndicator();
                    }

                    return separator;
                  },
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

class _ChatBottomBar extends StatelessWidget {
  const _ChatBottomBar({required this.receiver});

  final UserPreview receiver;

  @override
  Widget build(BuildContext context) {
    final (isBlockedByMe, isBlockedByOther) = context
        .select<ChatSessionCubit, (bool, bool)>(
          (cubit) => (cubit.isBlockedByMe, cubit.isBlockedByOther),
        );

    final status = context.select<ItemStatusCubit, ItemStatus>(
      (c) => switch (c.state) {
        ItemStatusSuccess(status: final status) => status,
        _ => ItemStatus.unknown,
      },
    );

    final _isChatDisabled =
        !(status == ItemStatus.approved || status == ItemStatus.unknown);

    final child = switch ((_isChatDisabled, isBlockedByMe, isBlockedByOther)) {
      (_, true, _) => GestureDetector(
        onTap: () async {
          final shouldUnblock =
              await BlockUserDialog.show(
                context,
                user: receiver,
                isUserBlocked: isBlockedByMe,
              ) ??
              false;

          if (shouldUnblock) {
            context.read<UserBlockCubit>().toggleBlockUser(
              userId: receiver.id,
              isUserBlocked: isBlockedByMe,
            );
          }
        },
        child: Text(
          'youBlockedThisContact'.translate(context),
          textAlign: TextAlign.center,
        ),
      ),
      (_, _, true) => Text(
        'youCanNoLongerSendMessagesToThisContact'.translate(context),
        textAlign: TextAlign.center,
      ),
      (true, false, false) => Text(
        '${'thisItemIs'.translate(context)} ${status.label.translate(context)}',
        textAlign: TextAlign.center,
      ),
      (false, false, false) => const MessageComposer(),
    };

    return ColoredBox(
      color: context.colorScheme.secondary,
      child: Padding(
        padding: EdgeInsets.only(
          bottom:
              MediaQuery.paddingOf(context).bottom +
              MediaQuery.viewInsetsOf(context).bottom +
              10,
          top: 8,
        ),
        child: child,
      ),
    );
  }
}
