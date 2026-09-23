import 'package:eClassify/features/favorite/cubits/item_favorite_cubit.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/utils/debounce_mixin.dart';
import 'package:eClassify/core/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    required this.itemId,
    required this.isLiked,
    super.key,
  });

  final int itemId;
  final bool isLiked;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with DebounceMixin<FavoriteButton, bool> {
  // This tracks the last known state saved on the server
  late bool _serverIsLiked;

  @override
  void initState() {
    super.initState();
    _serverIsLiked = widget.isLiked;
    if (widget.isLiked) {
      context.read<ItemFavoriteCubit>().initItemFavorite(widget.itemId);
    }
  }

  @override
  Duration get debounceDuration => const Duration(milliseconds: 500);

  @override
  void onDebounced(bool isLiked) async {
    if (_serverIsLiked == isLiked) return;
    _serverIsLiked = await context.read<ItemFavoriteCubit>().syncFavoriteState(
      widget.itemId,
      isLiked,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = context.select<ItemFavoriteCubit, bool>(
      (c) => c.isFavorite(widget.itemId),
    );

    return IconButton(
      style: IconButton.styleFrom(
        foregroundColor: context.colorScheme.primary,
        backgroundColor: context.colorScheme.secondary,
        elevation: 1,
        iconSize: 16,
        minimumSize: Size.square(36),
      ),
      onPressed: () {
        UiUtils.checkUser(
          onNotGuest: () {
            final newIsLiked = !isLiked;
            context.read<ItemFavoriteCubit>().toggleFavorite(
              widget.itemId,
              newIsLiked,
            );
            debounce(newIsLiked);
          },
          context: context,
        );
      },
      icon: Icon(isLiked ? AppIcons.heartFill : AppIcons.heart),
    );
  }
}
