// ignore_for_file: implementation_imports, depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:vs_media_picker/src/core/decode_image.dart';
import 'package:vs_media_picker/src/core/functions.dart';
import 'package:vs_media_picker/src/presentation/pages/vs_media_picker_controller.dart';

class GalleryThumbnail extends StatefulWidget {
  final int thumbnailQuality;
  final double thumbnailScale;
  final BoxFit thumbnailFit;
  final double? height;
  final double? width;
  const GalleryThumbnail({
    super.key,
    this.thumbnailQuality = 150,
    this.thumbnailScale = 1.0,
    this.thumbnailFit = BoxFit.cover,
    this.height,
    this.width,
  });

  @override
  State<GalleryThumbnail> createState() => _GalleryThumbnailState();
}

class _GalleryThumbnailState extends State<GalleryThumbnail> {
  /// create object of PickerDataProvider
  final provider = VSMediaPickerController();

  @override
  void initState() {
    GalleryFunctions.getPermission(setState, provider);
    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      provider.pickedFile.clear();
      provider.picked.clear();
      provider.pathList.clear();
      PhotoManager.stopChangeNotify();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return provider.pathList.isNotEmpty
        ? Image(
            image: DecodeImage(provider.pathList[0],
                thumbSize: widget.thumbnailQuality,
                index: 0,
                scale: widget.thumbnailScale),
            fit: widget.thumbnailFit,
            height: widget.height,
            width: widget.width,
            filterQuality: FilterQuality.low,
          )
        : const SizedBox();
  }
}
