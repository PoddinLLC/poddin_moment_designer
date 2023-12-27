// ignore_for_file: library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
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
    Alignment.bottomCenter,
    Alignment.bottomLeft,
    Alignment.bottomRight,
    Alignment.centerRight,
    Alignment.center
  ];
  double? imgHeight;
  double? imgWidth;

  @override
  void initState() {
    // get image size
    Timer(Duration.zero, () async {
      final fileByte = await widget.filePath!.readAsBytes();
      final buffer = await ui.ImmutableBuffer.fromUint8List(fileByte);
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final width = descriptor.width * 1.0;
      final height = descriptor.height * 1.0;
      // get image aspect ratio
      final aspectRatio = width / height;
      // resize image to fit screen width
      imgWidth = widget.dimension!.width;
      imgHeight = (widget.dimension!.width ~/ aspectRatio).toDouble();
      if (mounted) setState(() {});
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorProvider = Provider.of<GradientNotifier>(context, listen: false);
    //
    return RepaintBoundary(
      key: paintKey,
      child: ImagePixels(
        imageProvider: FileImage(File(widget.filePath!.path)),
        defaultColor: Colors.black,
        builder: (context, img) {
          var color1 = img.pixelColorAtAlignment!(color1alignment[value]);
          var color2 = img.pixelColorAtAlignment!(color2alignment[value]);
          colorProvider.color1 = color1;
          colorProvider.color2 = color2;
          //
          return Image.file(
            File(widget.filePath!.path),
            key: imageKey,
            width: (imgWidth ?? widget.dimension!.width) * widget.scale!,
            height: (imgHeight ?? widget.dimension!.height) * widget.scale!,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          );
        },
      ),
    );
  }
}
