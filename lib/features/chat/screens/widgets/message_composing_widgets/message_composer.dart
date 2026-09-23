import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:eClassify/core/constants/constant.dart';
import 'package:eClassify/core/theme/theme_colors.dart';
import 'package:eClassify/core/utils/file_picker_utility.dart';
import 'package:eClassify/core/utils/log.dart';
import 'package:eClassify/features/chat/cubits/chat_message_cubit.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/attachment_preview.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/chat_template_list.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/message_audio_button.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/message_audio_input.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/message_input_field.dart';
import 'package:eClassify/features/chat/screens/widgets/message_composing_widgets/message_send_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({super.key});

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _controller = TextEditingController();

  // Recording states
  final ValueNotifier<bool> _isRecording = ValueNotifier(false);
  final ValueNotifier<bool> _isPaused = ValueNotifier(false);
  final ValueNotifier<Duration> _recordingDuration = ValueNotifier(
    Duration.zero,
  );
  final ValueNotifier<List<double>> _amplitudes = ValueNotifier(const []);

  // Attachment states
  final ValueNotifier<File?> _stagedFile = ValueNotifier(null);

  late final AudioRecorder _recorder = AudioRecorder();
  Timer? _timer;
  StreamSubscription<Amplitude>? _ampSub;

  // Rolling amplitude buffer cap — older samples scroll off.
  static const int _maxAmplitudeSamples = 60;

  // How often the recorder emits an amplitude sample; also the glide duration.
  static const Duration _sampleInterval = Duration(milliseconds: 100);

  @override
  void dispose() {
    _controller.dispose();
    _isRecording.dispose();
    _isPaused.dispose();
    _recordingDuration.dispose();
    _amplitudes.dispose();
    _stagedFile.dispose();
    _ampSub?.cancel();
    _recorder.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer({bool reset = true}) {
    _timer?.cancel();
    if (reset) _recordingDuration.value = Duration.zero;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration.value += const Duration(seconds: 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Normalizes the recorder's dBFS reading (~-60..0) to a 0..1 bar height.
  double _normalizeAmplitude(double dbfs) {
    const floor = -60.0;
    return ((dbfs - floor) / -floor).clamp(0.0, 1.0);
  }

  void _startAmplitudeStream() {
    _amplitudes.value = const [];
    _ampSub?.cancel();
    _ampSub = _recorder.onAmplitudeChanged(_sampleInterval).listen((amp) {
      final next = [..._amplitudes.value, _normalizeAmplitude(amp.current)];
      if (next.length > _maxAmplitudeSamples) {
        next.removeRange(0, next.length - _maxAmplitudeSamples);
      }
      _amplitudes.value = next;
    });
  }

  Future<bool> _handleRecordingStart() async {
    try {
      if (await _recorder.hasPermission(request: false)) {
        final tempDir = await getTemporaryDirectory();
        final path = '${tempDir.path}/${const Uuid().v4()}.m4a';

        await _recorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );

        _isRecording.value = true;
        _isPaused.value = false;
        _startTimer();
        _startAmplitudeStream();
        return true;
      }
    } catch (e, st) {
      log('${e.toString()} $st');
      Log.error('Failed to start recording', e, st);
    }
    _recorder.hasPermission(request: true);
    return false;
  }

  Future<void> _togglePause() async {
    try {
      if (_isPaused.value) {
        await _recorder.resume();
        _isPaused.value = false;
        _startTimer(reset: false);
        _ampSub?.resume();
      } else {
        await _recorder.pause();
        _isPaused.value = true;
        _stopTimer();
        _ampSub?.pause();
      }
    } catch (e, st) {
      Log.error('Failed to toggle pause', e, st);
    }
  }

  Future<void> _resetRecordingState() async {
    await _ampSub?.cancel();
    _ampSub = null;
    _isRecording.value = false;
    _isPaused.value = false;
    _amplitudes.value = const [];
    _stopTimer();
  }

  void _sendRecording() async {
    final path = await _recorder.stop();
    await _resetRecordingState();

    if (path != null && mounted) {
      context.read<ChatMessageCubit>().sendMessage(audio: File(path));
    }
  }

  void _discardRecording() async {
    final path = await _recorder.stop();
    await _resetRecordingState();

    if (path != null) {
      final file = File(path);
      if (file.existsSync()) file.deleteSync();
    }
    debugPrint("Recording Discarded");
  }

  void _pickAttachment() async {
    final files = await FilePickerUtility.pick(
      allowMultiple: false,
      type: FileType.image,
      allowedExtensions: ['jpeg', 'jpg', 'png'],
    );

    if (files != null && files.isNotEmpty) {
      _stagedFile.value = files.first;
    }
  }

  void _handleSend() {
    final text = _controller.text.trim();
    final file = _stagedFile.value;

    if (text.isNotEmpty || file != null) {
      context.read<ChatMessageCubit>().sendMessage(
        text: text.isNotEmpty ? text : null,
        attachment: file,
      );
      _controller.clear();
      _stagedFile.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_isRecording, _stagedFile]),
      builder: (context, _) {
        final isRecording = _isRecording.value;
        final stagedFile = _stagedFile.value;

        if (isRecording) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constant.horizontalPadding,
            ),
            child: _InputBackground(
              child: MessageAudioInput(
                duration: _recordingDuration,
                isPaused: _isPaused,
                amplitudes: _amplitudes,
                sampleInterval: _sampleInterval,
                onDelete: _discardRecording,
                onPauseToggle: _togglePause,
                onSend: _sendRecording,
              ),
            ),
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (stagedFile != null)
              AttachmentPreview(
                file: stagedFile,
                onRemove: () => _stagedFile.value = null,
              )
            else
              ChatTemplateList(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constant.horizontalPadding,
              ),
              child: Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: _InputBackground(
                      child: MessageInputField(
                        controller: _controller,
                        onAttach: _pickAttachment,
                        onSubmitted: (_) => _handleSend(),
                      ),
                    ),
                  ),
                  _buildTrailingButton(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrailingButton() {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _stagedFile]),
      builder: (context, child) {
        final hasContent =
            _controller.text.trim().isNotEmpty || _stagedFile.value != null;

        if (hasContent) {
          return MessageSendButton(onSend: _handleSend);
        }

        return MessageAudioButton(onRecordStart: _handleRecordingStart);
      },
    );
  }
}

class _InputBackground extends StatelessWidget {
  const _InputBackground({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: context.colorScheme.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: child,
        ),
      ),
    );
  }
}
