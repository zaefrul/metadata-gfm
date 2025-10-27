import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final File? file;
  final String? url;
  final String? path;

  const ImageViewer({super.key, this.url, this.path, this.file})
      : assert(url != null || path != null || file != null,
            'One of url, path, or file must be provided.');

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    
    if (url != null) {
      imageWidget = Image.network(
        url!,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.broken_image,
                  color: Colors.grey,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      );
    } else if (file != null) {
      imageWidget = Image.file(file!);
    } else {
      imageWidget = Image.file(File(path!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Viewer"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: imageWidget,
      ),
    );
  }
}
