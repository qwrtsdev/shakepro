import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:provider/provider.dart';
import '../settings.dart';

class VoiceRecorderPage extends StatefulWidget {
  const VoiceRecorderPage({super.key});
  @override
  State<VoiceRecorderPage> createState() => _VoiceRecorderPageState();
}

class _VoiceRecorderPageState extends State<VoiceRecorderPage> {
  final _recorder = AudioRecorder();
  final _player = AudioPlayer();
  bool _isRecording = false;

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        await _player.play(DeviceFileSource(path));
      }
    } else {
      if (!await _recorder.hasPermission()) return;
      final path =
          '/storage/emulated/0/Documents/SoftDevDemo/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      final quality = context.read<SettingsModel>().recordingQuality;
      final int bitRate;
      final int sampleRate;
      switch (quality) {
        case 'High':
          bitRate = 256000;
          sampleRate = 48000;
          break;
        case 'Low':
          bitRate = 16000;
          sampleRate = 4000;
          break;
        case 'Medium':
        default:
          bitRate = 64000;
          sampleRate = 22050;
      }

      await _recorder.start(
        RecordConfig(bitRate: bitRate, sampleRate: sampleRate),
        path: path,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Recording to $path')),
        );
      }
      setState(() => _isRecording = true);
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isRecording ? Icons.mic : Icons.mic_none,
            size: 80,
            color: _isRecording ? Colors.red : Colors.grey,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _toggleRecording,
            child: Text(_isRecording ? 'Stop & Play' : 'Start Recording'),
          ),
        ],
      ),
    );
  }
}
