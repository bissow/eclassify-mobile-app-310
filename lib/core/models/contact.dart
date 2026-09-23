import 'package:flutter/foundation.dart';

@immutable
class Contact {
  const Contact({
    this.number = '',
    this.regionCode = '',
    this.callingCode = '',
  });

  /// Creates an empty [Contact] instance.
  factory Contact.empty() => const Contact();

  /// Deserializes a [Contact] from a JSON map.
  /// Handles common API key aliases for phone/mobile numbers, region codes, and calling codes.
  factory Contact.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const Contact();

    final rawNumber = (json['number'] ?? json['mobile'] ?? json['phone_number']) as String? ?? '';
    final rawRegion = (json['region_code'] ?? json['regionCode'] ?? json['country_iso_code']) as String? ?? '';
    final rawCalling = (json['calling_code'] ?? json['callingCode'] ?? json['country_code'] ?? json['phone_code']) as String? ?? '';

    return Contact(
      number: rawNumber,
      regionCode: rawRegion,
      callingCode: rawCalling,
    );
  }

  /// The national phone number string (e.g. "9876543210" or "4155552671").
  final String number;

  /// The 2-letter ISO region code (e.g. "US", "IN", "GB").
  final String regionCode;

  /// The international country calling code without or with '+' (e.g. "1", "91", "+44").
  final String callingCode;

  /// Returns true if the phone number string is blank.
  bool get isEmpty => number.trim().isEmpty;

  /// Returns true if the phone number string is non-blank.
  bool get isNotEmpty => !isEmpty;

  /// Formatted calling code with a leading '+' (e.g., "+1", "+91").
  String get formattedCallingCode {
    final cleanCode = callingCode.trim().replaceAll('+', '');
    if (cleanCode.isEmpty) return '';
    return '+$cleanCode';
  }

  /// Standard E.164 phone string format (e.g., "+14155552671").
  /// Returns empty string if number is empty.
  String get e164 {
    if (isEmpty) return '';
    final digitsOnly = number.replaceAll(RegExp(r'\D'), '');
    final prefix = formattedCallingCode;
    return '$prefix$digitsOnly';
  }

  /// Serializes this [Contact] into a standard JSON map.
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'region_code': regionCode,
      'calling_code': callingCode,
    };
  }

  /// Returns a copy of this [Contact] with the given fields replaced.
  Contact copyWith({
    String? number,
    String? regionCode,
    String? callingCode,
  }) {
    return Contact(
      number: number ?? this.number,
      regionCode: regionCode ?? this.regionCode,
      callingCode: callingCode ?? this.callingCode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Contact &&
        other.number == number &&
        other.regionCode == regionCode &&
        other.callingCode == callingCode;
  }

  @override
  int get hashCode => Object.hash(number, regionCode, callingCode);

  @override
  String toString() => 'Contact(number: $number, regionCode: $regionCode, callingCode: $callingCode)';
}
