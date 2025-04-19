import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<File?> getCompressedImage(ImageSource source) async {
  // Pick the image from the specified source
  final picked = await ImagePicker().pickImage(
    source: source,
    maxWidth: 480,
    maxHeight: 640,
  );
  if (picked == null) return null;
  
  File originalFile = File(picked.path);
  
  // Compress the image using flutter_image_compress
  Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
    originalFile.path,
    quality: 60,
    minWidth: 480,
    minHeight: 640,
  );
  
  if (compressedBytes == null) return null;
  
  // Get a temporary directory to store the compressed image
  final tempDir = await getTemporaryDirectory();
  final targetPath = '${tempDir.path}/compressed_${p.basename(originalFile.path)}';
  
  // Write the compressed bytes to a new file
  File compressedFile = File(targetPath);
  await compressedFile.writeAsBytes(compressedBytes);
  
  return compressedFile;
}

Future<Uint8List?> compressFile(File file, {dynamic settings}) async {
  settings ??= defaultCompressParams;
  final compressedBytes = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    quality: settings['quality'],
    minWidth: settings['minWidth'],
    minHeight: settings['minHeight']
  );
  
  if (compressedBytes == null) {
    return null;
  }
  return Uint8List.fromList(compressedBytes);
}

Map<String, dynamic> defaultCompressParams = {
  'quality': Platform.isIOS ? 60 : 100,
  'minWidth': 480,
  'minHeight': 640,
};