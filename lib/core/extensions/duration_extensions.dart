extension DurationFormatting on Duration {
  /// Formats as `mm:ss`, e.g. `Duration.zero` -> `00:00`, 75s -> `01:15`.
  /// Minutes overflow past 60 (90 min -> `90:00`) rather than rolling into hours.
  String get mmss {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
