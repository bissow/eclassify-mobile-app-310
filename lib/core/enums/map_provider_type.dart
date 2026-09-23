enum MapProviderType {
  freeApi,
  googleMap;

  static MapProviderType fromRaw(String raw) {
    return raw == 'free_api'
        ? MapProviderType.freeApi
        : MapProviderType.googleMap;
  }

  bool get isFreeApi => this == MapProviderType.freeApi;
  bool get isPaidApi => !isFreeApi;
}
