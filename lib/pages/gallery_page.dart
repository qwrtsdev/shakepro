import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

class Gallery extends StatefulWidget {
  const Gallery({super.key});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<File> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    if (await Permission.photos.request().isGranted) {
      final dir = Directory('/storage/emulated/0/Documents/SoftDevDemo');
      if (await dir.exists()) {
        final files = await dir.list().toList();
        setState(() {
          _images = files
              .whereType<File>()
              .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.builder(
        scrollCacheExtent: const ScrollCacheExtent.pixels(1000),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) => GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenViewer(imageFile: _images[index]),
              ),
            );
          },
          child: Image(
            image: ResizeImage(FileImage(_images[index]), width: 200),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class FullScreenViewer extends StatelessWidget {
  final File imageFile;

  const FullScreenViewer({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Image.file(imageFile),
      ),
    );
  }
}
