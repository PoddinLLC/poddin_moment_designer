// ignore_for_file: no_leading_underscores_for_local_identifiers, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:vs_media_picker/vs_media_picker.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:poddin_moment_designer/src/domain/sevices/save_as_image.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/text_animation_type.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/animated_onTap_button.dart';
import '../../domain/models/editable_items.dart';
import 'package:gallery_asset_picker/gallery_asset_picker.dart';

// import 'package:poddin_moment_designer/src/presentation/widgets/tool_button.dart';

class BottomTools extends StatefulWidget {
  final GlobalKey contentKey;
  final Function(String imageUri) onDone;
  final Widget? onDoneButtonStyle;
  final Function? renderWidget;

  /// editor background color
  final Color? editorBackgroundColor;
  //
  const BottomTools(
      {Key? key,
      required this.contentKey,
      required this.onDone,
      this.renderWidget,
      this.onDoneButtonStyle,
      this.editorBackgroundColor})
      : super(key: key);

  @override
  _BottomToolsState createState() => _BottomToolsState();
}

class _BottomToolsState extends State<BottomTools> {
  //
  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    bool _createVideo = false;
    GalleryAssetPicker.initialize(GalleryConfig(
      enableCamera: true,
      crossAxisCount: 3,
      colorScheme: const ColorScheme.dark(primary: Color(0xFFD91C54)),
      onReachMaximum: () {
        Fluttertoast.showToast(
          msg: "You have reached the allowed number of images",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      },
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ));
    //
    return Consumer4<ControlNotifier, ScrollNotifier, DraggableWidgetNotifier,
        PaintingNotifier>(
      builder: (_, controlNotifier, scrollNotifier, itemNotifier,
          paintingNotifier, __) {
        return SizedBox(
          height: 70, //95
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// preview gallery
              Container(
                padding: const EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  child: _preViewContainer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(90),
                      child: GestureDetector(
                        onTap: () async {
                          // Launch camera
                          final photos = await GalleryAssetPicker.pick(
                            context,
                            maxCount: 1,
                            requestType: RequestType.image,
                          );
                          final paths =
                              photos.map((e) => e.pickedFile!.path).toList();
                          // set media path value
                          if (itemNotifier.uploadedMedia == 0) {
                            controlNotifier.mediaPath = paths[0];
                            setState(() {});
                          }
                          // add media to view
                          itemNotifier
                            ..draggableWidget.add(EditableItem()
                              ..type = ItemType.image
                              ..path = paths[0]
                              ..position = const Offset(0.0, 0))
                            ..uploadedMedia = 1
                            ..clearMediaPath(controlNotifier);
                          setState(() {});

                          /// scroll to gridView page
                          //  if (controlNotifier.mediaPath.isEmpty) {
                          // scrollNotifier.pageController.animateToPage(1,
                          //     duration:
                          //         const Duration(milliseconds: 300),
                          //     curve: Curves.ease);
                          //  }
                        },
                        child: const CoverThumbnail(
                            // thumbnailQuality: 150,
                            ),
                      ),
                    ),
                  ),
                ),
              ),

              /// center logo
              controlNotifier.middleBottomWidget != null
                  ? Center(
                      child: Container(
                          width: _size.width / 2,
                          constraints: const BoxConstraints(maxHeight: 40),
                          alignment: Alignment.bottomCenter,
                          child: controlNotifier.middleBottomWidget),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/instagram_logo.png',
                            package: 'poddin_moment_designer',
                            color: Colors.white,
                            height: 42,
                          ),
                          const Text(
                            'Story Designer',
                            style: TextStyle(
                                color: Colors.white38,
                                letterSpacing: 1.5,
                                fontSize: 9.2,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

              /// save final image to gallery
              AnimatedOnTapButton(
                  onTap: () async {
                    String pngUri;
                    if (paintingNotifier.lines.isNotEmpty ||
                        itemNotifier.draggableWidget.isNotEmpty) {
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Card(
                                  color: Colors.black,
                                  child: Container(
                                    padding: const EdgeInsets.all(50),
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                      for (var element in itemNotifier.draggableWidget) {
                        if (element.type == ItemType.gif ||
                            element.animationType != TextAnimationType.none) {
                          _createVideo = true;
                        }
                      }
                      if (_createVideo) {
                        debugPrint('creating video');
                        await widget.renderWidget!();
                      } else {
                        debugPrint('creating image');
                        await takePicture(
                                contentKey: widget.contentKey,
                                context: context,
                                saveToGallery: false,
                                fileName: controlNotifier.folderName)
                            .then((bytes) {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (bytes != null) {
                            pngUri = bytes;
                            widget.onDone(pngUri);
                          } else {
                            debugPrint("error");
                          }
                        });
                      }
                    } else {
                      Fluttertoast.showToast(msg: 'Add a picture or text');
                    }
                    _createVideo = false;
                  },
                  child: widget.onDoneButtonStyle ??
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.white, width: 1.2)),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 0, right: 2),
                                child: Icon(Icons.share_sharp, size: 28),
                              ),
                            ]),
                      ))
            ],
          ),
        );
      },
    );
  }

  Widget _preViewContainer({child}) {
    return Container(
      height: 36,
      width: 36,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          //borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.2, color: Colors.white)),
      child: child,
    );
  }
}
