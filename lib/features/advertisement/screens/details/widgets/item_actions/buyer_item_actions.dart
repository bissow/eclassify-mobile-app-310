import 'package:eClassify/app/routes.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/features/chat/cubits/safety_tips_cubit.dart';
import 'package:eClassify/features/advertisement/screens/details/widgets/modals/create_offer_dialog.dart';
import 'package:eClassify/features/chat/screens/widgets/modals/safety_tips_bottom_sheet.dart';
import 'package:eClassify/features/chat/cubits/item_offer_cubit.dart';
import 'package:eClassify/features/item/models/item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BuyerItemAction extends StatefulWidget {
  const BuyerItemAction({required this.item, super.key});

  final Item item;

  @override
  State<BuyerItemAction> createState() => _BuyerItemActionState();
}

class _BuyerItemActionState extends State<BuyerItemAction> {
  late bool _showOfferButton =
      !widget.item.hasAlreadyOffered &&
      widget.item.hasPrice &&
      !widget.item.isJobItem;

  late int? _itemOfferId = widget.item.itemOfferId;

  late bool _showApplyButton =
      widget.item.isJobItem && !widget.item.hasAlreadyJobApplied;

  void _onCreateOffer(BuildContext context) {
    final offerState = context.read<ItemOfferCubit>().state;
    if (offerState is ItemOfferLoading) return;
    UiUtils.checkUser(
      onNotGuest: () async {
        await context.read<SafetyTipsListCubit>().fetchSafetyTips();
        if (!context.mounted) return;

        final state = context.read<SafetyTipsListCubit>().state;
        if (state is SafetyTipsListSuccess) {
          final continueToOffer = await SafetyTipsBottomSheet.show(
            context,
            tips: state.tips,
          );
          if (!context.mounted || !continueToOffer) return;
        }
        // SafetyTipsFailure (or any non-success) falls through silently to the offer dialog

        final offerPrice = await CreateOfferDialog.show(
          context,
          formattedPrice: widget.item.price!,
          currency: widget.item.currency,
        );

        if (offerPrice != null) {
          context.read<ItemOfferCubit>().createOffer(
            id: widget.item.id,
            amount: offerPrice,
          );
        }
      },
      context: context,
    );
  }

  void _onChatTap(BuildContext context) {
    final offerState = context.read<ItemOfferCubit>().state;
    if (offerState is ItemOfferLoading) return;
    UiUtils.checkUser(
      onNotGuest: () {
        if (_itemOfferId != null) {
          Navigator.of(
            context,
          ).pushNamed(Routes.chatScreen, arguments: {'id': _itemOfferId});
        } else {
          context.read<ItemOfferCubit>().createOffer(id: widget.item.id);
        }
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ItemOfferCubit, ItemOfferState>(
      listener: (context, state) {
        if (state is ItemOfferSuccess) {
          setState(() {
            _showOfferButton = false;
          });
          _itemOfferId = state.chat.id;
          Navigator.of(
            context,
          ).pushNamed(Routes.chatScreen, arguments: {'chat_user': state.chat});
        }
        if (state is ItemOfferFailure) {
          HelperUtils.showSnackBarMessage(context, state.errorMessage);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        spacing: 16,
        children: [
          if (_showOfferButton)
            Expanded(
              child: AppButton(
                variant: AppButtonVariant.filled,
                onPressed: () => _onCreateOffer(context),
                child: BlocBuilder<SafetyTipsListCubit, SafetyTipsListState>(
                  builder: (context, tipsState) {
                    if (tipsState is SafetyTipsListLoading) {
                      return LoadingIndicator.inlineDots();
                    }
                    return BlocBuilder<ItemOfferCubit, ItemOfferState>(
                      builder: (context, state) {
                        if (state case ItemOfferLoading(
                          :final trigger,
                        ) when trigger == OfferTrigger.offer) {
                          return LoadingIndicator.inlineDots();
                        }
                        return Text('makeAnOffer'.translate(context));
                      },
                    );
                  },
                ),
              ),
            ),
          if (_showApplyButton)
            Expanded(
              child: AppButton(
                variant: AppButtonVariant.filled,
                onPressed: () async {
                  final didApply =
                      await Navigator.of(context).pushNamed(
                            Routes.jobApplicationForm,
                            arguments: widget.item.id,
                          )
                          as bool? ??
                      false;

                  if (didApply) {
                    setState(() {
                      _showApplyButton = false;
                    });
                  }
                },
                title: 'applyNow',
              ),
            ),
          Expanded(
            child: AppButton(
              variant: AppButtonVariant.filled,
              onPressed: () => _onChatTap(context),
              child: BlocBuilder<ItemOfferCubit, ItemOfferState>(
                builder: (context, state) {
                  if (state case ItemOfferLoading(
                    :final trigger,
                  ) when trigger == OfferTrigger.chat) {
                    return LoadingIndicator.inlineDots();
                  }
                  return Text('chat'.translate(context));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
