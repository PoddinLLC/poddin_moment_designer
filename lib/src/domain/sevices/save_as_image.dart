import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future takePicture({
  required contentKey,
  required BuildContext context,
  required saveToGallery,
  required fileName,
}) async {
  try {
    /// converter widget to image
    RenderRepaintBoundary boundary =
        contentKey.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 3);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    /// create file
    final String dir = (await getApplicationDocumentsDirectory()).path;
    String imagePath =
        '$dir/${fileName}_${DateTime.now().millisecondsSinceEpoch}.png';
    File capturedFile = File(imagePath);
    await capturedFile.writeAsBytes(pngBytes);

    /// compress image
    String targetpath =
        '$dir/${fileName}_${DateTime.now().millisecondsSinceEpoch}.png';
    final compressedImage = await FlutterImageCompress.compressAndGetFile(
      imagePath,
      targetpath,
      minWidth: 1080,
      minHeight: 1920,
      quality: 70,
      format: CompressFormat.png,
    );
    String finalpath = compressedImage!.path;

    if (saveToGallery) {
      final result = await ImageGallerySaver.saveImage(pngBytes,
          quality: 100,
          name: "${fileName}_${DateTime.now().microsecondsSinceEpoch}");
      if (result != null) {
        return true;
      } else {
        return false;
      }
    } else {
      return finalpath;
    }
  } catch (e) {
    debugPrint('exception => $e');
    return false;
  }
}
