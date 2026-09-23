import 'package:eClassify/core/constants/app_icons.dart';
import 'package:eClassify/core/extensions/duration_extensions.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/pulsating_dot_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// WhatsApp-style two-layer recording panel.
///
/// Top: recording indicator + elapsed duration + live amplitude bars.
/// Bottom: Delete / Pause-Resume / Send.
class MessageAudioInput extends StatelessWidget {
  const MessageAudioInput({
    required this.duration,
    required this.isPaused,
    required this.amplitudes,
    required this.sampleInterval,
    required this.onDelete,
    required this.onPauseToggle,
    required this.onSend,
    super.key,
  });

  final ValueListenable<Duration> duration;
  final ValueListenable<bool> isPaused;
  final ValueListenable<List<double>> amplitudes;

  /// How often a new amplitude sample arrives. Drives the glide animation so
  /// the bars scroll continuously between samples instead of stepping.
  final Duration sampleInterval;
  final VoidCallback onDelete;
  final VoidCallback onPauseToggle;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top layer: indicator + duration + amplitude bars
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: isPaused,
                builder: (context, paused, _) => paused
                    ? const Icon(
                        AppIcons.pauseFill,
                        color: Colors.red,
                        size: 18,
                      )
                    : const PulsatingDotIndicator(color: Colors.red),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<Duration>(
                valueListenable: duration,
                builder: (context, value, _) => Text(
                  value.mmss,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LiveWaveform(
                  amplitudes: amplitudes,
                  sampleInterval: sampleInterval,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Bottom layer: Delete / Pause / Send
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(AppIcons.trash, color: Colors.grey),
                onPressed: onDelete,
                tooltip: 'delete'.translate(context),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: isPaused,
                builder: (context, paused, _) => IconButton(
                  icon: Icon(
                    paused ? AppIcons.microphoneFill : AppIcons.pauseFill,
                  ),
                  onPressed: onPauseToggle,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  fixedSize: const Size.square(40),
                  iconSize: 24,
                ),
                icon: const Icon(AppIcons.paperPlaneRightFill),
                onPressed: onSend,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Continuously scrolling waveform. Each amplitude sample restarts a short
/// glide (0..1 over one sample interval) so the whole bar row slides smoothly
/// toward the trailing edge instead of snapping one slot per sample.
class _LiveWaveform extends StatefulWidget {
  const _LiveWaveform({required this.amplitudes, required this.sampleInterval});

  final ValueListenable<List<double>> amplitudes;
  final Duration sampleInterval;

  @override
  State<_LiveWaveform> createState() => _LiveWaveformState();
}

class _LiveWaveformState extends State<_LiveWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glide = AnimationController(
    vsync: this,
    duration: widget.sampleInterval,
  );

  @override
  void initState() {
    super.initState();
    widget.amplitudes.addListener(_onSample);
  }

  // A new sample landed: restart the glide from the leading edge.
  void _onSample() => _glide.forward(from: 0);

  @override
  void dispose() {
    widget.amplitudes.removeListener(_onSample);
    _glide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      // Breathing room at the trailing edge so a shrinking bar never touches
      // the duration text sitting to its left (right in RTL).
      padding: const EdgeInsetsDirectional.only(start: 12),
      child: AnimatedBuilder(
        animation: _glide,
        builder: (context, _) => CustomPaint(
          willChange: true,
          size: const Size.fromHeight(32),
          painter: _RecordingWavePainter(
            amplitudes: widget.amplitudes.value,
            phase: _glide.value,
            color: context.colorScheme.primary,
            isRTL: isRTL,
          ),
        ),
      ),
    );
  }
}

/// Paints the live recording waveform: newest sample at the leading edge,
/// older samples scrolling toward the trailing edge. Bar heights are driven
/// by normalized amplitudes (0..1), unlike the seeded-random playback bars.
/// [phase] (0..1) is the sub-slot glide offset toward the next sample.
class _RecordingWavePainter extends CustomPainter {
  const _RecordingWavePainter({
    required this.amplitudes,
    required this.phase,
    required this.color,
    required this.isRTL,
  });

  final List<double> amplitudes;
  final double phase;
  final Color color;
  final bool isRTL;

  static const double _barWidth = 3.0;
  static const double _spacing = 6.0;
  static const double _minHeight = 4.0;

  // How many slots the grow-in / shrink-out ramp spans. Larger = gentler,
  // slower reveal (each slot ≈ one sample interval).
  static const double _rampSlots = 2.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Keep the bars that fit plus a little runway so the oldest can finish its
    // shrink-out ramp before being culled.
    final fit = (size.width / _spacing).floor();
    final maxBars = fit + _rampSlots.ceil();
    final visible = amplitudes.length > maxBars
        ? amplitudes.sublist(amplitudes.length - maxBars)
        : amplitudes;

    // Reference point (in slot units) where a bar has fully shrunk back to the
    // minimum stub, right before it leaves.
    final exitRef = maxBars - 1;

    // Glide the whole row by up to one slot toward the trailing edge so the
    // motion is continuous between discrete samples.
    final glide = phase * _spacing;
    for (int i = 0; i < visible.length; i++) {
      // Newest sample sits at the leading edge (right in LTR, left in RTL).
      final slot = isRTL ? i : (visible.length - 1 - i);
      final x = isRTL
          ? size.width - _spacing * slot - _spacing / 2 + glide
          : size.width - _spacing * slot - _spacing / 2 - glide;

      // Continuous age of this bar in slot units: 0 = just entered at the
      // leading edge, rising as it drifts toward the trailing edge.
      final p = slot + phase;
      final entry = (p / _rampSlots).clamp(0.0, 1.0);
      final exit = ((exitRef - p) / _rampSlots).clamp(0.0, 1.0);
      final env = entry < exit ? entry : exit;

      // Grow from the min stub to the amplitude-driven height and back.
      final amplitudePart =
          visible[i].clamp(0.0, 1.0) * (size.height - _minHeight);
      final h = (_minHeight + amplitudePart * env).clamp(
        _minHeight,
        size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: _barWidth,
            height: h,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RecordingWavePainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes || oldDelegate.phase != phase;
  }
}
