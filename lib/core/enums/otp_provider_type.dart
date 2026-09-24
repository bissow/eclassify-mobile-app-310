enum OtpProviderType {
  firebase,
  twilio,
  test;

  static OtpProviderType fromRaw(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower == 'firebase') {
      return OtpProviderType.firebase;
    } else if (lower == 'test' || lower == 'test_otp' || lower == 'default') {
      return OtpProviderType.test;
    }
    return OtpProviderType.twilio;
  }

  bool get isFirebase => this == OtpProviderType.firebase;
}
