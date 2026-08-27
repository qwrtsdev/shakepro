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

  static const double _shakeThreshold = 18.0;

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
    if (g > _shakeThreshold && _countdown == 0) {
      _runCountdownAndCapture();
    }
  }

  Future<void> _runCountdownAndCapture() async {
    for (int i = 3; i >= 1; i--) {
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    final file = await _controller?.takePicture();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Captured! Saved to ${file?.path}')),
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