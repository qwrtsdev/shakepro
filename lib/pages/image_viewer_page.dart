import 'package:flutter/material.dart';

class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({super.key});

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Viewer')),
      body: const Center(
        child: Text('Image viewer page'),
      ),
    );
  }
}
