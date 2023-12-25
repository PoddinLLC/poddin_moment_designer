// ignore_for_file: library_private_types_in_public_api, no_leading_underscores_for_local_identifiers
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/gradient_notifier.dart';
import 'dart:async';
import 'package:poddin_moment_designer/src/presentation/utils/color_detection.dart';
import 'package:provider/provider.dart';

class FileImageBG extends StatefulWidget {
  final File? filePath;
  final Size? dimension;
  final double? scale;
  // final void Function(Color color1, Color color2) generatedGradient;
  const FileImageBG({
    super.key,
    required this.filePath,
    // this.generatedGradient,
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

  GlobalKey? currentKey;

  final StreamController<Color> stateController = StreamController<Color>();

  @override
  void initState() {
    var colorProvider = Provider.of<GradientNotifier>(context, listen: false);
    currentKey = paintKey;
    Timer.periodic(const Duration(milliseconds: 200), (callback) async {
      if (widget.scale! >= 1) {
        var cd1 = await ColorDetection(
          currentKey: currentKey,
          paintKey: paintKey,
          stateController: stateController,
        ).searchPixel(Offset(widget.dimension!.width / 2.03, 480));
        var cd2 = await ColorDetection(
          currentKey: currentKey,
          paintKey: paintKey,
          stateController: stateController,
        ).searchPixel(Offset(widget.dimension!.width / 2.03, 530));
        colorProvider.color1 = cd1;
        colorProvider.color2 = cd2;
        callback.cancel();
        stateController.close();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: paintKey,
      child: Image.file(
        width: widget.dimension!.width * widget.scale!,
        height: widget.dimension!.height * widget.scale!,
        File(widget.filePath!.path),
        key: imageKey,
        fit: BoxFit.cover,
      ),
    );
  }
}
