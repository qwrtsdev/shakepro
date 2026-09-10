import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:provider/provider.dart';
import '../settings.dart';

class CameraShakePage extends StatefulWidget {
  const CameraShakePage({super.key});
  @override
  State<CameraShakePage> createState() => _CameraShakePageState();
}

class _CameraShakePageState extends State<CameraShakePage> {
  CameraController? _controller;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _accelSub = accelerometerEventStream().listen(_onAccel);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    final resolution = context.read<SettingsModel>().photoQuality == 'Max'
        ? ResolutionPreset.max
        : context.read<SettingsModel>().photoQuality == 'High'
            ? ResolutionPreset.high
            : context.read<SettingsModel>().photoQuality == 'Medium'
                ? ResolutionPreset.medium
                : ResolutionPreset.low;
    _controller = CameraController(cameras.first, resolution);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _onAccel(AccelerometerEvent e) {
    final g = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    final thresholdpercentage = context.read<SettingsModel>().sensitivity;
    final threshold = 10 + (thresholdpercentage / 100 * (50 - 10));
    if (g > threshold && _countdown == 0) {
      _runCountdownAndCapture();
    }
  }

  Future<void> _runCountdownAndCapture() async {
    final countdown = context.read<SettingsModel>().countdown;
    for (int i = countdown; i >= 1; i--) {
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    final file = await _controller?.takePicture();
    final targetDirectory =
        Directory('/storage/emulated/0/Documents/SoftDevDemo');

    final String fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final String targetPath = '${targetDirectory.path}/$fileName';

    await file?.saveTo(targetPath);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Captured to ${targetPath}')),
      );
    }
    setState(() => _countdown = 0);
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: CameraPreview(_controller!)),
        Positioned(
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              _countdown > 0 ? '$_countdown' : 'Shake it!!!',
              style: const TextStyle(color: Colors.white, fontSize: 35),
            ),
          ),
        ),
      ],
    );
  }
}
