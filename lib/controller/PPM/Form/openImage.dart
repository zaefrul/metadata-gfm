import 'dart:io';

import 'package:flutter/material.dart';

class ImageViewer extends StatelessWidget {
  final File file;
  final String url;
  final String path;
  final Image image;

  ImageViewer({this.url, this.path, this.file})
      : image = url == null
            ? file != null
                ? Image.file(File(file.path))
                : Image.file(File(path))
            : Image.network(url);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Text("Photo Viewer"),
      ),
      body: Container(
        child: new Center(
          child: image,
        ),
      ),
    );
  }
}
