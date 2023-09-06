// ignore_for_file: no_leading_underscores_for_local_identifiers

import "package:images_picker/images_picker.dart";
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

// import 'package:poddin_moment_designer/src/presentation/widgets/tool_button.dart';

class BottomTools extends StatelessWidget {
  final GlobalKey contentKey;
  final Function(String imageUri) onDone;
  final Widget? onDoneButtonStyle;
  final Function? renderWidget;

  /// editor background color
  final Color? editorBackgroundColor;
  const BottomTools(
      {Key? key,
      required this.contentKey,
      required this.onDone,
      this.renderWidget,
      this.onDoneButtonStyle,
      this.editorBackgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    bool _createVideo = false;
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
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: () async {
                          // Launch camera
                          final photos = await ImagesPicker.openCamera(
                            pickType: PickType.image,
                            maxSize: 6000,
                            quality: 0.8,
                            language: Language.English,
                            maxTime: 15,
                          );
                          final paths = photos!.map((e) => e.path).toList();
                          // set media path value
                          if (itemNotifier.uploadedMedia == 0) {
                            controlNotifier.mediaPath = paths[0];
                          }
                          // add media to view
                          itemNotifier
                            ..draggableWidget.add(EditableItem()
                              ..type = ItemType.image
                              ..path = paths[0]
                              ..position = const Offset(0.0, 0))
                            ..addMedia()
                            ..clearMediaPath(controlNotifier);
                          // clear media path
                          if (itemNotifier.uploadedMedia >= 1 &&
                              controlNotifier.mediaPath.isNotEmpty) {
                            controlNotifier.mediaPath = '';
                            controlNotifier.gradientIndex += 1;
                          }
                          // set uploadedMedia value
                          itemNotifier.uploadedMedia++;

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
                          constraints: const BoxConstraints(maxHeight: 42),
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
                        await renderWidget!();
                      } else {
                        debugPrint('creating image');
                        await takePicture(
                                contentKey: contentKey,
                                context: context,
                                saveToGallery: false,
                                fileName: controlNotifier.folderName)
                            .then((bytes) {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (bytes != null) {
                            pngUri = bytes;
                            onDone(pngUri);
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
                  child: onDoneButtonStyle ??
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.white, width: 1.5)),
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
      height: 45,
      width: 45,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 1.4, color: Colors.white)),
      child: child,
    );
  }

  // /bagr  colors

  // Widget _selectColor({onTap, controlProvider}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 5, right: 0, top: 0),
  //     child: AnimatedOnTapButton(
  //       onTap: onTap,
  //       child: Container(
  //         padding: const EdgeInsets.all(2),
  //         decoration: BoxDecoration(
  //             // border: Border.all(
  //             //   color: Colors.white,
  //             // ),
  //             // borderRadius: BorderRadius.circular(8)
  //             // // shape: BoxShape.circle,
  //             ),
  //         child: Container(
  //           width: 45,
  //           height: 45,
  //           decoration: BoxDecoration(
  //             border: Border.all(
  //               color: Colors.white,
  //             ),
  //             borderRadius: BorderRadius.circular(8),

  //             gradient: LinearGradient(
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //                 colors: controlProvider
  //                     .gradientColors![controlProvider.gradientIndex]),
  //             // border: Border.all(
  //             //     // color: Colors.white,
  //             //     ),
  //             //  shape: BoxShape.circle,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
