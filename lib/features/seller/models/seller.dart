import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/models/user_placeholder.dart';
import 'package:eClassify/core/utils/json_helper.dart';

class Seller {
  Seller({
    required this.id,
    required this.name,
    required this.email,
    required this.profile,
    required this.isVerified,
    required this.showPersonalDetails,
    required this.reviewsCount,
    required this.averageRating,
    required this.isFollowing,
    this.contact = const Contact(),
    this.placeholder,
    this.joinedAt,
    this.followers,
    this.following,
  });

  Seller.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      email = json['email'] as String? ?? '',
      contact = Contact.fromJson(json),
      profile = json['profile'] as String? ?? '',
      isVerified = json['is_verified'] is bool
          ? json['is_verified']
          : (json['is_verified'] as int?) == 1,
      showPersonalDetails = (json['show_personal_details'] as int?) == 1,
      reviewsCount = json['reviews_count'] as int? ?? 0,
      averageRating = json['average_rating'] as num? ?? 0.0,
      placeholder = UserPlaceholder.fromJson(json),
      isFollowing = json['is_following'] is bool
          ? json['is_following']
          : json['is_following'] == 1,
      joinedAt = DateTime.tryParse(json['created_at'] as String? ?? ''),
      followers = json['followers_count'] as int? ?? 0,
      following = json['following_count'] as int? ?? 0;

  final int id;
  final String name;
  final String email;
  final Contact contact;
  final String profile;
  final bool isVerified;
  final bool showPersonalDetails;
  final int reviewsCount;
  final num averageRating;
  final UserPlaceholder? placeholder;
  final bool isFollowing;
  final DateTime? joinedAt;
  final int? followers;
  final int? following;

  Seller copyWith({int? followers, bool? isFollowing}) => Seller(
    id: id,
    name: name,
    email: email,
    profile: profile,
    isVerified: isVerified,
    showPersonalDetails: showPersonalDetails,
    reviewsCount: reviewsCount,
    averageRating: averageRating,
    isFollowing: isFollowing ?? this.isFollowing,
    contact: contact,
    placeholder: placeholder,
    joinedAt: joinedAt,
    followers: followers ?? this.followers,
    following: following,
  );

  @override
  bool operator ==(Object other) =>
      other is Seller &&
      id == other.id &&
      name == other.name &&
      email == other.email &&
      contact == other.contact &&
      profile == other.profile &&
      isVerified == other.isVerified &&
      showPersonalDetails == other.showPersonalDetails &&
      reviewsCount == other.reviewsCount &&
      averageRating == other.averageRating &&
      isFollowing == other.isFollowing &&
      joinedAt == other.joinedAt &&
      followers == other.followers &&
      following == other.following;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    contact,
    profile,
    isVerified,
    showPersonalDetails,
    reviewsCount,
    averageRating,
    isFollowing,
    joinedAt,
    followers,
    following,
  );
}
