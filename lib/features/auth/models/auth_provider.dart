enum AuthProvider {
  email,
  phone,
  google,
  apple;

  String get raw => name;

  static AuthProvider? fromRaw(String? raw) {
    for (final provider in AuthProvider.values) {
      if (provider.raw == raw) return provider;
    }
    return null;
  }
}
