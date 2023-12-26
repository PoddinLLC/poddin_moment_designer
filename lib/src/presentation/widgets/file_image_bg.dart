// ignore_for_file: library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_pixels/image_pixels.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:provider/provider.dart';

class FileImageBG extends StatefulWidget {
  final File? filePath;
  final Size? dimension;
  final double? scale;
  const FileImageBG({
    super.key,
    required this.filePath,
    required this.dimension,
    required this.scale,
  });
  //
  @override
  _FileImageBGState createState() => _FileImageBGState();
}

class _FileImageBGState extends State<FileImageBG> {
  GlobalKey imageKey = GlobalKey();
  GlobalKey paintKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<GradientNotifier>(context, listen: false);
    return RepaintBoundary(
      key: paintKey,
      child: ImagePixels(
        imageProvider: FileImage(File(widget.filePath!.path)),
        defaultColor: Colors.black,
        builder: (context, img) {
          var color1 = img.pixelColorAtAlignment!(Alignment.topLeft);
          var color2 = img.pixelColorAtAlignment!(Alignment.center);
          colorProvider.color1 = color1;
          colorProvider.color2 = color2;
          return Image.file(
            width: widget.dimension!.width * widget.scale!,
            height: widget.dimension!.height * widget.scale!,
            File(widget.filePath!.path),
            key: imageKey,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          );
        },
      ),
    );
  }
}
