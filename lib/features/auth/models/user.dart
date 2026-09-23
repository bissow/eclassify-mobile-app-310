import 'package:eClassify/core/models/contact.dart';
import 'package:eClassify/core/models/user_placeholder.dart';
import 'package:eClassify/core/utils/json_helper.dart';
import 'package:eClassify/features/auth/models/auth_provider.dart';

class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.contact = const Contact(),
    this.profile,
    this.placeholder,
    this.address,
    this.fcmId,
    this.fcmTokens = const [],
    this.authProvider,
    required this.showPersonalDetails,
    required this.notificationsEnabled,
    required this.isVerified,
    this.hasStore = false,
  });

  User.fromJson(Json json)
    : id = json['id'] as int,
      name = json['name'] as String,
      email = json['email'] as String,
      contact = Contact.fromJson(json),
      profile = json['profile'] as String?,
      placeholder = UserPlaceholder.fromJson(json),
      address = json['address'] as String?,
      fcmId = json['fcm_id'] as String?,
      fcmTokens = _parseFcmTokens(json['fcm_tokens']),
      authProvider = AuthProvider.fromRaw(json['type'] as String?),
      showPersonalDetails = (json['show_personal_details'] as int?) == 1,
      notificationsEnabled = (json['notification'] as int?) == 1,
      isVerified = (json['is_verified'] as int?) == 1,
      hasStore = json['has_store'] == true || json['has_store'] == 1;

  final int id;
  final String name;
  final String email;
  final Contact contact;
  final String? profile;
  final UserPlaceholder? placeholder;
  final String? address;
  final String? fcmId;

  /// Every device token the backend holds for this user (`fcm_tokens` on
  /// get-user-info). Used to detect a rotated/expired token on this device.
  final List<String>? fcmTokens;
  final AuthProvider? authProvider;

  /// get-user-info sends `[{fcm_token, platform_type, ...}]`; the Hive copy
  /// written by [toJson] stores the plain strings. Accept both.
  static List<String> _parseFcmTokens(Object? raw) => switch (raw) {
    final List list => [
      for (final e in list)
        if (e is String)
          e
        else if (e is Map && e['fcm_token'] is String)
          e['fcm_token'] as String,
    ],
    _ => const [],
  };

  final bool showPersonalDetails;
  final bool notificationsEnabled;
  final bool isVerified;
  final bool hasStore;

  User copyWith({
    String? name,
    String? email,
    Contact? contact,
    String? address,
    String? fcmId,
    bool? showPersonalDetails,
    bool? notificationsEnabled,
    bool? hasStore,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      profile: profile,
      placeholder: placeholder,
      address: address ?? this.address,
      fcmId: fcmId ?? this.fcmId,
      fcmTokens: fcmTokens,
      authProvider: authProvider,
      showPersonalDetails: showPersonalDetails ?? this.showPersonalDetails,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isVerified: isVerified,
      hasStore: hasStore ?? this.hasStore,
    );
  }

  Json toJson() => {
    'id': id,
    'name': name,
    'email': email,
    ...contact.toJson(),
    'profile': profile,
    ...?placeholder?.toJson(),
    'address': address,
    'fcm_id': fcmId,
    'fcm_tokens': fcmTokens,
    'type': authProvider?.raw,
    'show_personal_details': showPersonalDetails ? 1 : 0,
    'notification': notificationsEnabled ? 1 : 0,
    'is_verified': isVerified ? 1 : 0,
  };
}
