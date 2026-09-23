import 'package:eClassify/features/auth/session_scoped.dart';
import 'package:eClassify/features/favorite/repository/favourites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ItemFavoriteCubit extends Cubit<Map<int, bool>> with SessionScoped {
  ItemFavoriteCubit() : super({});

  /// Seed as liked; caller only invokes this when server isLiked true
  void initItemFavorite(int itemId) {
    if (!state.containsKey(itemId)) emit({...state, itemId: true});
  }

  /// [value] takes priority; falls back to toggling current isFavorite
  void toggleFavorite(int itemId, [bool? value]) {
    emit({...state, itemId: value ?? !isFavorite(itemId)});
  }

  Future<bool> syncFavoriteState(int itemId, bool isLiked) async {
    try {
      await FavoriteRepository.instance.toggleFavorite(itemId: itemId);
    } catch (e) {
      toggleFavorite(itemId, !isLiked);
    } finally {
      return isFavorite(itemId);
    }
  }

  /// To check if an item is liked
  bool isFavorite(int itemId) => state[itemId] ?? false;

  /// Clear the state of cubit during logout process
  void clear() => emit({});

  @override
  void clearSessionState() => clear();
}
