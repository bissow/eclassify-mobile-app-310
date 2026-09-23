import 'package:eClassify/app/routes.dart';
import 'package:eClassify/features/chat/cubits/item_offer_cubit.dart';
import 'package:eClassify/features/reels/models/video_ad.dart';
import 'package:eClassify/core/widgets/feedback/loading_indicator.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/utils/helper_utils.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReelChatButton extends StatelessWidget {
  const ReelChatButton({required this.ad, super.key});

  final VideoAd ad;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ItemOfferCubit(),
      child: Builder(
        builder: (context) {
          return BlocConsumer<ItemOfferCubit, ItemOfferState>(
            listener: (context, state) {
              if (state is ItemOfferSuccess) {
                Navigator.of(context).pushNamed(
                  Routes.chatScreen,
                  arguments: {'chat_user': state.chat},
                );
              } else if (state is ItemOfferFailure) {
                HelperUtils.showSnackBarMessage(context, state.errorMessage);
              }
            },
            builder: (context, state) {
              final isLoading = state is ItemOfferLoading;

              return Column(
                children: [
                  IconButton(
                    onPressed: () {
                      if (isLoading) return;
                      UiUtils.checkUser(
                        onNotGuest: () {
                          if (ad.itemOfferId != null) {
                            Navigator.of(context).pushNamed(
                              Routes.chatScreen,
                              arguments: {'id': ad.itemOfferId},
                            );
                          } else {
                            context.read<ItemOfferCubit>().createOffer(
                              id: ad.item.id,
                            );
                          }
                        },
                        context: context,
                      );
                    },
                    icon: isLoading
                        ? LoadingIndicator.inlineDots()
                        : const Icon(AppIcons.chatCircleText),
                  ),
                  Text(
                    'chat'.translate(context),
                    style: context.titleSmall.withColor(Colors.white),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
