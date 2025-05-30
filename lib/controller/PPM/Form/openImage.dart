import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final File? file;
  final String? url;
  final String? path;
  final Image image;

  ImageViewer({super.key, this.url, this.path, this.file})
      : assert(url != null || path != null || file != null,
            'One of url, path, or file must be provided.'),
        image = url != null
            ? Image.network(url)
            : file != null
                ? Image.file(file)
                : Image.file(File(path!));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Photo Viewer"),
      ),
      body: Container(
        alignment: Alignment.center,
        child: image,
      ),
    );
  }
}
