// ignore_for_file: library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'dart:io';
import 'dart:math';
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
  final value = Random().nextInt(5);
  final color1alignment = [
    Alignment.topCenter,
    Alignment.topRight,
    Alignment.topLeft,
    Alignment.centerLeft,
    Alignment.center
  ];
  final color2alignment = [
    Alignment.center,
    Alignment.bottomLeft,
    Alignment.centerRight,
    Alignment.bottomCenter,
    Alignment.bottomRight
  ];
  double imgHeight = double.infinity;
  double imgWidth = double.infinity;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<GradientNotifier>(context, listen: false);
    var height = min(widget.dimension!.height, imgHeight);
    var width = min(widget.dimension!.width, imgWidth);
    //
    return RepaintBoundary(
      key: paintKey,
      child: ImagePixels(
        imageProvider: FileImage(File(widget.filePath!.path)),
        defaultColor: Colors.black,
        builder: (context, img) {
          var color1 =
              img.pixelColorAtAlignment!(color1alignment.elementAt(value));
          var color2 =
              img.pixelColorAtAlignment!(color2alignment.elementAt(value));
          //
          imgHeight = img.hasImage
              ? (img.height! > height)
                  ? img.height! / 1.5
                  : img.height! * 1.0
              : imgHeight;
          imgWidth = img.hasImage
              ? (img.width! > width)
                  ? img.width! / 1.5
                  : img.width! * 1.0
              : imgHeight;
          setState(() {});
          //
          colorProvider.color1 = color1;
          colorProvider.color2 = color2;
          //
          return Image.file(
            width: width * widget.scale!,
            height: height * widget.scale!,
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
