/// Implemented by any cubit whose state is tied to the current session and
/// must not leak into the next one — data belonging to whoever was logged
/// in before. Reset whenever `AuthSessionCubit` emits `Unauthenticated`,
/// regardless of why (logout, account deletion, or a 401 from the backend).
mixin SessionScoped {
  void clearSessionState();
}
