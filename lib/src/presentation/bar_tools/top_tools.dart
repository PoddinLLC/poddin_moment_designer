// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:poddin_moment_designer/src/domain/sevices/save_as_image.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/text_animation_type.dart';
import 'package:poddin_moment_designer/src/presentation/utils/modal_sheets.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/animated_onTap_button.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/tool_button.dart';

class TopTools extends StatefulWidget {
  final GlobalKey contentKey;
  final BuildContext context;
  final Function? renderWidget;
  const TopTools(
      {super.key,
      required this.contentKey,
      required this.context,
      this.renderWidget});

  @override
  _TopToolsState createState() => _TopToolsState();
}

class _TopToolsState extends State<TopTools> {
  bool _createVideo = false;
  @override
  Widget build(BuildContext context) {
    return Consumer3<ControlNotifier, PaintingNotifier,
        DraggableWidgetNotifier>(
      builder: (_, controlNotifier, paintingNotifier, itemNotifier, __) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                /// close button
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () async {
                    if (itemNotifier.draggableWidget.isEmpty ||
                        paintingNotifier.lines.isEmpty) {
                      Navigator.pop(context);
                    } else {
                      exitDialog(
                              context: widget.context,
                              contentKey: widget.contentKey,
                              themeType: controlNotifier.themeType)
                          .then((res) {
                        if (res) Navigator.pop(context);
                      });
                    }
                  },
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Change background color
                        if (controlNotifier.mediaPath.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _selectColor(
                                controlProvider: controlNotifier,
                                onTap: () {
                                  if (controlNotifier.gradientIndex >=
                                      controlNotifier.gradientColors!.length -
                                          1) {
                                    setState(() {
                                      controlNotifier.gradientIndex = 0;
                                    });
                                  } else {
                                    setState(() {
                                      controlNotifier.gradientIndex += 1;
                                    });
                                  }
                                }),
                          ),

                        // Add text
                        ToolButton(
                          backGroundColor: Colors.black12,
                          onTap: () => controlNotifier.isTextEditing =
                              !controlNotifier.isTextEditing,
                          child: const ImageIcon(
                            AssetImage('assets/icons/text.png',
                                package: 'poddin_moment_designer'),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),

                        // Toggle text shadow
                        ToolButton(
                          backGroundColor: controlNotifier.enableTextShadow
                              ? Colors.white
                              : Colors.black12,
                          onTap: () {
                            controlNotifier.enableTextShadow =
                                !controlNotifier.enableTextShadow;
                          },
                          child: Icon(Icons.text_fields_sharp,
                              color: controlNotifier.enableTextShadow
                                  ? Colors.black
                                  : Colors.white,
                              size: 24),
                        ),

                        // Add sticker
                        // ToolButton(
                        //     child: const ImageIcon(
                        //       AssetImage('assets/icons/stickers.png',
                        //           package: 'poddin_moment_designer'),
                        //       color: Colors.white,
                        //       size: 20,
                        //     ),
                        //     backGroundColor: Colors.black12,
                        //     onTap: () => createGiphyItem(
                        //         context: context,
                        //         giphyKey: controlNotifier.giphyKey),),

                        // Add drawing
                        ToolButton(
                          backGroundColor: Colors.black12,
                          onTap: () {
                            controlNotifier.isPainting = true;
                          },
                          child: const ImageIcon(
                            AssetImage('assets/icons/draw.png',
                                package: 'poddin_moment_designer'),
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 5),

                // ToolButton(
                //   child: ImageIcon(
                //     const AssetImage('assets/icons/photo_filter.png',
                //         package: 'poddin_moment_designer'),
                //     color: controlNotifier.isPhotoFilter ? Colors.black : Colors.white,
                //     size: 20,
                //   ),
                //   backGroundColor:  controlNotifier.isPhotoFilter ? Colors.white70 : Colors.black12,
                //   onTap: () => controlNotifier.isPhotoFilter =
                //   !controlNotifier.isPhotoFilter,
                // ),

                // Download image
                ToolButton(
                  backGroundColor: Colors.black12,
                  onTap: () async {
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
                                        margin: const EdgeInsets.all(50),
                                        child: const CircularProgressIndicator(
                                          color: Colors.white,
                                        ))),
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
                        debugPrint('creating video');
                        await widget.renderWidget!();
                      } else {
                        debugPrint('creating image');
                        var response = await takePicture(
                            contentKey: widget.contentKey,
                            context: context,
                            saveToGallery: true,
                            fileName: controlNotifier.folderName);
                        if (response) {
                          Fluttertoast.showToast(msg: 'Saved to gallery!');
                        }
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.of(context, rootNavigator: true).pop();
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Add a picture or type something');
                    }
                  },
                  child: const ImageIcon(
                    AssetImage('assets/icons/download.png',
                        package: 'poddin_moment_designer'),
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// gradient color selector
  Widget _selectColor({onTap, controlProvider}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: AnimatedOnTapButton(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 1.2),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: controlProvider
                    .gradientColors![controlProvider.gradientIndex]),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
