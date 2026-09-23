import 'package:eClassify/features/item/models/item_preview.dart';
import 'package:eClassify/features/seller/models/seller.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class VideoAd {
  VideoAd({
    required this.id,
    required this.itemId,
    required this.video,
    required this.thumbnail,
    required this.likeCount,
    required this.isLiked,
    required this.item,
    this.itemOfferId,
    this.seller,
  });

  VideoAd.fromJson(Json json)
    : id = json['id'] as int,
      itemId = json['item_id'] as int,
      itemOfferId = json['item_offer_id'] as int?,
      seller = JsonHelper.parseObjectOrNull(
        json['item_owner'] as Json?,
        Seller.fromJson,
      ),
      video = json['video'] as String,
      thumbnail = json['thumbnail'] as String,
      likeCount = json['liked_count'] as int,
      isLiked = json['is_liked'] as bool? ?? false,
      item = JsonHelper.parseObject(json['item'] as Json, ItemPreview.fromJson);

  final int id;
  final int itemId;
  final int? itemOfferId;
  final Seller? seller;
  final String video;
  final String thumbnail;
  final int likeCount;
  final bool isLiked;
  final ItemPreview item;

  VideoAd copyWith({int? likeCount, bool? isLiked}) {
    return VideoAd(
      id: id,
      itemId: itemId,
      video: video,
      thumbnail: thumbnail,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      item: item,
      itemOfferId: itemOfferId,
      seller: seller,
    );
  }
}
