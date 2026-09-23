enum OtpProviderType {
  firebase,
  twilio;

  static OtpProviderType fromRaw(String raw) {
    return raw == 'firebase'
        ? OtpProviderType.firebase
        : OtpProviderType.twilio;
  }
}
