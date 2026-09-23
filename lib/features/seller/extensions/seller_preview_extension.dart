import 'package:eClassify/core/models/user_preview.dart';
import 'package:eClassify/features/seller/models/seller.dart';

extension SellerPreview on Seller {
  /// Projects this [Seller] onto the lightweight [UserPreview] used by
  /// follow lists and chat headers.
  UserPreview toPreview() => UserPreview(
    id: id,
    name: name,
    profile: profile,
    placeholder: placeholder,
  );
}
