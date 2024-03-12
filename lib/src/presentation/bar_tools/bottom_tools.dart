// ignore_for_file: no_leading_underscores_for_local_identifiers, library_private_types_in_public_api, unused_import

import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/tool_button.dart';
import 'package:provider/provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:poddin_moment_designer/src/domain/sevices/save_as_image.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/text_animation_type.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/animated_onTap_button.dart';
import 'package:vs_media_picker/vs_media_picker.dart';
import '../../domain/models/editable_items.dart';

// import 'package:poddin_moment_designer/src/presentation/widgets/tool_button.dart';

class BottomTools extends StatefulWidget {
  final GlobalKey contentKey;
  final Function(String imageUri) onDone;
  final Widget? onDoneButtonStyle;
  final Function? renderWidget;
  final Function? iosAction;

  /// editor background color
  final Color? editorBackgroundColor;
  //
  const BottomTools(
      {super.key,
      required this.contentKey,
      required this.onDone,
      this.renderWidget,
      this.onDoneButtonStyle,
      this.editorBackgroundColor,
      this.iosAction});

  @override
  _BottomToolsState createState() => _BottomToolsState();
}

class _BottomToolsState extends State<BottomTools> {
  //
  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    bool _createVideo = false;
    //
    return Consumer4<ControlNotifier, ScrollNotifier, DraggableWidgetNotifier,
        PaintingNotifier>(
      builder: (_, controlNotifier, scrollNotifier, itemNotifier,
          paintingNotifier, __) {
        final page = controlNotifier.initialPage;
        //
        return Container(
          height: 70,
          padding: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // open camera
              if (Platform.isAndroid)
                ToolButton(
                  size: const Size.square(45),
                  backGroundColor: Colors.black12,
                  padding: const EdgeInsets.only(left: 15),
                  onLongPress: null,
                  onTap: () {
                    // if page = 1, initial mode is camera
                    // camera page index is 0, editor page index is 1
                    scrollNotifier.pageController.animateToPage(
                      page == 1 ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  },
                  child: const Icon(
                    Icons.camera,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              // open gallery
              if (!Platform.isAndroid)
                Padding(
                  padding: const EdgeInsets.only(left: 15, top: 8),
                  child: AwesomeOrientedWidget(
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      splashFactory: NoSplash.splashFactory,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        widget.iosAction!();
                      },
                      child: ClipOval(
                        child: Container(
                          height: 45,
                          width: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50.0),
                            child: const CoverThumbnail(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              /// center logo
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Center(
                  child: Container(
                    width: _size.width / 2,
                    constraints: const BoxConstraints(maxHeight: 45),
                    alignment: Alignment.bottomCenter,
                    child: controlNotifier.middleBottomWidget,
                  ),
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
                                  padding: const EdgeInsets.all(40),
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
                        setState(() {
                          _createVideo = true;
                        });
                      }
                    }
                    if (_createVideo) {
                      if (kDebugMode) debugPrint('creating video');
                      await widget.renderWidget!();
                    } else {
                      if (kDebugMode) debugPrint('creating image');
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
                        }
                      });
                    }
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Add a picture or type something');
                  }
                },
                child: widget.onDoneButtonStyle!,
              )
            ],
          ),
        );
      },
    );
  }
}
