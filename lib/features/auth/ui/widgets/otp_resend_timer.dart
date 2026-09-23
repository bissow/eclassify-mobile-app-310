import 'dart:async';

import 'package:eClassify/core/widgets/inputs/app_button.dart';
import 'package:eClassify/core/theme/theme_extensions.dart';
import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/extensions/string_extensions.dart';
import 'package:flutter/material.dart';

/// Shows a countdown while an OTP resend is on cooldown, then swaps to a
/// "Resend OTP" button once it elapses. [duration] defaults to
/// [Constant.otpTimeOutSecond] — the same window Firebase's own
/// auto-verification/resend uses elsewhere in the app.
class OtpResendTimer extends StatefulWidget {
  const OtpResendTimer({required this.onResend, this.duration, super.key});

  final VoidCallback onResend;
  final Duration? duration;

  @override
  State<OtpResendTimer> createState() => _OtpResendTimerState();
}

class _OtpResendTimerState extends State<OtpResendTimer> {
  late Duration _remaining = _initialDuration;
  Timer? _timer;

  Duration get _initialDuration =>
      widget.duration ?? Duration(seconds: Constant.otpTimeOutSecond);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _remaining = _initialDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds <= 1) {
        timer.cancel();
        setState(() => _remaining = Duration.zero);
      } else {
        setState(() => _remaining -= const Duration(seconds: 1));
      }
    });
  }

  void _handleResend() {
    widget.onResend();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining == Duration.zero) {
      return AppButton(
        variant: AppButtonVariant.text,
        width: AppButtonWidth.content,
        onPressed: _handleResend,
        title: 'resendOTP',
      );
    }

    final seconds = _remaining.inSeconds.toString().padLeft(2, '0');
    return Text(
      '${'resendOTPIn'.translate(context, {'duration': '00:$seconds'})}',
      style: context.bodyMedium.muted(context),
    );
  }
}
