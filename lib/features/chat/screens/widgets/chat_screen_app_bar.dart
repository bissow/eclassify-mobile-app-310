import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/currency_extension.dart';
import 'package:eClassify/core/extensions/generic_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/utils/collection_notifiers.dart';
import 'package:eClassify/core/widgets/images/custom_image.dart';
import 'package:eClassify/core/widgets/images/profile_avatar.dart';
import 'package:eClassify/core/widgets/images/user_placeholder_image.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/advertisement/cubits/item_status_cubit.dart';
import 'package:eClassify/features/chat/cubits/safety_tips_cubit.dart';
import 'package:eClassify/features/chat/screens/widgets/modals/safety_tips_bottom_sheet.dart';
import 'package:eClassify/features/chat/cubits/chat_message_cubit.dart';
import 'package:eClassify/features/chat/cubits/chat_session_cubit.dart';
import 'package:eClassify/features/chat/cubits/delete_chat_cubit.dart';
import 'package:eClassify/features/chat/cubits/user_block_cubit.dart';
import 'package:eClassify/features/chat/screens/inbox/widgets/chat_delete_confirmation_dialog.dart';
import 'package:eClassify/features/chat/screens/widgets/modals/block_user_dialog.dart';
import 'package:eClassify/features/chat/screens/widgets/modals/create_offer_bottom_sheet.dart';
import 'package:eClassify/features/item/enums/item_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatScreenAppBar({
    required this.selectionNotifier,
    required this.onDelete,
    required this.showOfferBar,
    this.isSelectionMode = false,
    super.key,
  });

  final SetNotifier<int> selectionNotifier;
  final VoidCallback onDelete;
  final bool showOfferBar;
  final bool isSelectionMode;

  Future<void> _handleBlockUser(
    BuildContext context,
    bool isUserBlocked,
    UserPreview user,
  ) async {
    final shouldProceed =
        await BlockUserDialog.show(
          context,
          user: user,
          isUserBlocked: isUserBlocked,
        ) ??
        false;

    if (shouldProceed && context.mounted) {
      context.read<UserBlockCubit>().toggleBlockUser(
        userId: user.id,
        isUserBlocked: isUserBlocked,
      );
    }
  }

  Future<void> _handleDeleteChat(BuildContext context, int chatId) async {
    final confirmed = await ChatDeleteConfirmationDialog.show(context) ?? false;
    if (confirmed && context.mounted) {
      context.read<DeleteChatCubit>().deleteChats(itemOfferIds: [chatId]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.read<ChatSessionCubit>().state;
    final user = session.isCurrentUserSeller
        ? session.chat.buyer
        : session.chat.seller;
    return AppBar(
      titleSpacing: 0,
      leading: BackButton(
        onPressed: () {
          if (isSelectionMode) {
            selectionNotifier.clear();
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      title: isSelectionMode
          ? _DeleteMessageContent(
              notifier: selectionNotifier,
              onDelete: onDelete,
            )
          : _AppBarContent(user: user),
      actions: [
        if (!isSelectionMode)
          PopupMenuButton(
            icon: Icon(AppIcons.dotsThreeVertical),
            itemBuilder: (context) {
              final isUserBlocked = context
                  .read<ChatSessionCubit>()
                  .isBlockedByMe;
              return [
                PopupMenuItem(
                  onTap: () => _handleBlockUser(context, isUserBlocked, user),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(AppIcons.prohibit, size: 16),
                      Text(
                        isUserBlocked
                            ? "unblock".translate(context)
                            : "block".translate(context),
                      ),
                    ],
                  ),
                ),

                PopupMenuItem(
                  onTap: () => _handleDeleteChat(context, session.chat.id),
                  child: Row(
                    spacing: 8,
                    children: [
                      Icon(
                        AppIcons.trash,
                        size: 16,
                        color: context.colorScheme.error,
                      ),
                      Text(
                        "deleteChatTitle".translate(context),
                        style: context.bodyMedium.withColor(
                          context.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),
      ],
      bottom: showOfferBar && !isSelectionMode ? _OfferBar() : null,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight * (showOfferBar && !isSelectionMode ? 2 : 1),
  );
}

class _AppBarContent extends StatelessWidget {
  const _AppBarContent({required this.user});

  final UserPreview user;

  @override
  Widget build(BuildContext context) {
    final status = context.select<ItemStatusCubit, ItemStatus>(
      (c) => switch (c.state) {
        ItemStatusSuccess(status: final status) => status,
        _ => ItemStatus.unknown,
      },
    );

    final session = context.read<ChatSessionCubit>().state;
    final item = session.chat.item;
    final isCurrentUserSeller = session.isCurrentUserSeller;

    return Row(
      spacing: 20,
      children: [
        SizedBox.square(
          dimension: 40,
          child: Stack(
            children: [
              Positioned.fill(child: ProfileAvatar(src: item.image)),
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: CustomImage(
                  src: user.profile,
                  size: Size.square(20),
                  radius: 20,
                  errorImage: UserPlaceholderImage(
                    placeholder: user.placeholder,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    Routes.sellerProfileScreen,
                    arguments: {'seller_id': user.id},
                  );
                },
                child: Text(user.name, style: context.labelLarge),
              ),
              GestureDetector(
                onTap: () {
                  if (status == ItemStatus.approved || isCurrentUserSeller) {
                    Navigator.of(context).pushNamed(
                      Routes.adDetailsScreen,
                      arguments: {
                        'item_id': item.id,
                        'is_my_item': isCurrentUserSeller,
                      },
                    );
                  }
                },
                child: Text(
                  item.name,
                  style: context.labelSmall.muted(context),
                ),
              ),
            ],
          ),
        ),
        if (item.price.isNotNullAndNotEmpty)
          Text(
            item.price!,
            style: context.titleSmall.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}

class _DeleteMessageContent extends StatelessWidget {
  const _DeleteMessageContent({required this.notifier, required this.onDelete});

  final SetNotifier<int> notifier;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: notifier,
            builder: (context, child) {
              return Text(
                '${notifier.length} ${'selected'.translate(context)}',
                textAlign: TextAlign.center,
              );
            },
          ),
        ),

        IconButton(
          onPressed: onDelete,
          icon: Icon(AppIcons.trash),
          tooltip: "delete".translate(context),
        ),
      ],
    );
  }
}

class _OfferBar extends StatelessWidget implements PreferredSizeWidget {
  const _OfferBar();

  @override
  Widget build(BuildContext context) {
    final currentOffer = context.select<ChatSessionCubit, String?>(
      (c) => c.state.currentOffer,
    );
    final _session = context.read<ChatSessionCubit>().state;
    final item = _session.chat.item;

    final hasOffer =
        currentOffer != null &&
        num.tryParse(currentOffer.normalize(item.currency)) != null;

    return SizedBox(
      height: kToolbarHeight,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          border: Border(top: BorderSide(color: context.theme.dividerColor)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Constant.horizontalPadding),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasOffer) ...[
                      Text(
                        'currentOffer'.translate(context),
                        style: context.bodySmall,
                      ),
                      Text(currentOffer, style: context.labelLarge.bold),
                    ] else ...[
                      Text(
                        'makeAnOffer'.translate(context),
                        style: context.labelLarge,
                      ),
                      Text(
                        'makeAnOfferSubtitle'.translate(context),
                        style: context.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              AppButton(
                variant: AppButtonVariant.filled,
                width: AppButtonWidth.content,
                size: AppButtonSize.compact,
                onPressed: () async {
                  // Same gate as BuyerItemActions on the item details
                  // screen: safety tips before the first offer only —
                  // editing an existing one skips them. A failed fetch
                  // falls through to the offer sheet.
                  if (!hasOffer) {
                    final tipsCubit = context.read<SafetyTipsListCubit>();
                    await tipsCubit.fetchSafetyTips();
                    if (!context.mounted) return;
                    if (tipsCubit.state case SafetyTipsListSuccess(
                      :final tips,
                    )) {
                      final continueToOffer = await SafetyTipsBottomSheet.show(
                        context,
                        tips: tips,
                      );
                      if (!context.mounted || !continueToOffer) return;
                    }
                  }

                  final offer = await CreateOfferBottomSheet.show(
                    context,
                    itemPrice: item.price!,
                    currentOffer: currentOffer,
                    currency: item.currency,
                  );

                  if (offer != null) {
                    final normalized = offer.normalize(item.currency);
                    // Built to read like the server's formatted_amount so
                    // the confirmed message doesn't visibly reformat it.
                    final formatted = double.parse(
                      normalized,
                    ).formatAmount(item.currency, withSymbol: true);
                    context.read<ChatSessionCubit>().updateOffer(formatted);
                    context.read<ChatMessageCubit>().sendMessage(
                      offer: normalized,
                      formattedOffer: formatted,
                    );
                  }
                },
                child: BlocBuilder<SafetyTipsListCubit, SafetyTipsListState>(
                  builder: (context, state) {
                    if (!hasOffer && state is SafetyTipsListLoading) {
                      return LoadingIndicator.inlineDots();
                    }
                    return Text(
                      (hasOffer ? 'editOffer' : 'makeOffer').translate(context),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
