enum NotificationType {
  notification('notification', requiresAuth: false),
  itemUpdate('item-update'),
  itemEdit('item-edit', requiresAuth: false),
  chat('chat'),
  offer('offer'),
  payment('payment'),
  jobApplication('job-application'),
  applicationStatus('application-status'),
  itemReview('item-review'),
  verificationStatus('verifcation-request-update'),
  blog('blog', requiresAuth: false),
  unknown('', requiresAuth: false);

  const NotificationType(this.key, {this.requiresAuth = true});

  final String key;

  /// Whether a valid session is required before this notification should be
  /// surfaced to the user at all. Guarded centrally in
  /// [NotificationEventCubit] — before any payload parsing happens — so a
  /// stale notification arriving after logout never emits a state: no
  /// banner, no side effect, no tap navigation.
  ///
  /// This is intentionally per-type, not per-payload, and that's only safe
  /// when *parsing itself* doesn't depend on a session existing. `chat`/
  /// `offer` parsing reads `AppSession.currentUser!.id`
  /// (`Chat.fromNotification`), so those two must gate before parsing —
  /// there's no way to discover "this needs auth" without already having
  /// unsafely touched `currentUser!`. [notification], by contrast, forks
  /// into a public ad-details screen or the user's own notification list
  /// depending on payload shape, but neither branch's *parsing* touches
  /// session state — so it's marked `false` here, and the one branch that
  /// actually needs a session ([GenericNotification]) checks
  /// [AppSession.isAuthenticated] itself in `NotificationHandler` — the
  /// only such self-check left, now that every other type is fully gated
  /// upstream by this flag.
  final bool requiresAuth;

  static NotificationType? parse(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp('[^A-Za-z0-9]+'),
      '-',
    );

    return NotificationType.values.firstWhere(
      (element) => element.key == normalized,
      orElse: () => NotificationType.unknown,
    );
  }
}
