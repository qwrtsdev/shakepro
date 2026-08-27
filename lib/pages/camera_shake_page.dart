import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class CameraShakePage extends StatefulWidget {
  const CameraShakePage({super.key});
  @override
  State<CameraShakePage> createState() => _CameraShakePageState();
}

class _CameraShakePageState extends State<CameraShakePage> {
  CameraController? _controller;
  StreamSubscription<AccelerometerEvent>? _accelSub;

  int _countdown = 0;
  bool _busy = false;
  String? _lastPhotoPath;

  static const double _shakeThreshold = 20.0; // tune sensitivity here
  DateTime _lastShake = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initCamera();
    _accelSub = accelerometerEventStream().listen(_onAccel);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  void _onAccel(AccelerometerEvent e) {
    final g = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
    final now = DateTime.now();
    if (g > _shakeThreshold &&
        !_busy &&
        now.difference(_lastShake).inMilliseconds > 1500) {
      _lastShake = now;
      _runCountdownAndCapture();
    }
  }

  Future<void> _runCountdownAndCapture() async {
    setState(() => _busy = true);
    for (int i = 3; i >= 1; i--) {
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    setState(() => _countdown = 0);

    if (_controller != null && _controller!.value.isInitialized) {
      final file = await _controller!.takePicture();
      _lastPhotoPath = file.path;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved: ${file.path}')),
        );
      }
    }
    setState(() => _busy = false);
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
        if (_countdown > 0)
          Text(
            '$_countdown',
            style: const TextStyle(
              fontSize: 100,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 12)],
            ),
          ),
        Positioned(
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: Colors.black54,
            child: Text(
              _busy ? 'Hold still...' : 'Shake phone to take a photo',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
