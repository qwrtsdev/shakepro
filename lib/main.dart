import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/camera_shake_page.dart';
import 'pages/voice_recorder_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shake Cam & Recorder',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  final _pages = const [
    CameraShakePage(),
    VoiceRecorderPage(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => [Permission.camera, Permission.microphone].request(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Shake Cam',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Recorder',
          ),
        ],
      ),
    );
  }
}
