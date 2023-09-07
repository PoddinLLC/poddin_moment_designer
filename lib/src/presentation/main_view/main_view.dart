// ignore_for_file: must_be_immutable, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, deprecated_member_use, unnecessary_import
import 'dart:async';
import 'dart:io';
import 'package:camerawesome/pigeon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';
import 'package:poddin_moment_designer/src/domain/models/editable_items.dart';
import 'package:poddin_moment_designer/src/domain/models/painting_model.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/painting_notifier.dart';
// import 'package:poddin_moment_designer/src/domain/providers/notifiers/rendering_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/scroll_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/text_editing_notifier.dart';
// import 'package:poddin_moment_designer/src/domain/sevices/save_as_gif_mp4.dart';
import 'package:poddin_moment_designer/src/presentation/bar_tools/bottom_tools.dart';
import 'package:poddin_moment_designer/src/presentation/bar_tools/top_tools.dart';
import 'package:poddin_moment_designer/src/presentation/draggable_items/delete_item.dart';
import 'package:poddin_moment_designer/src/presentation/draggable_items/draggable_widget.dart';
// import 'package:poddin_moment_designer/src/presentation/main_view/widgets/rendering_indicator.dart';
import 'package:poddin_moment_designer/src/presentation/painting_view/painting.dart';
import 'package:poddin_moment_designer/src/presentation/painting_view/widgets/sketcher.dart';
import 'package:poddin_moment_designer/src/presentation/text_editor_view/TextEditor.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/font_family.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';
// import 'package:poddin_moment_designer/src/presentation/utils/constants/render_state.dart';
import 'package:poddin_moment_designer/src/presentation/utils/modal_sheets.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/scrollable_pageView.dart';
import 'package:poddin_moment_designer/poddin_moment_designer.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import "package:images_picker/images_picker.dart";

class MainView extends StatefulWidget {
  /// editor custom font families
  final List<FontType>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// you can pass a folderName where media files will be saved to instead of default folder
  final String? fileName;

  /// giphy api key
  final String giphyKey;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done
  final Function(String)? onDone;

  /// on done button Text
  final Widget? onDoneButtonStyle;

  /// on back pressed
  final Future<bool>? onBackPress;

  /// editor background color
  Color? editorBackgroundColor;

  /// gallery thumbnail quality
  final int? galleryThumbnailQuality;

  /// editor custom color palette list
  List<Color>? colorList;
  // Text appearing on center of design screen
  final String? centerText;

// theme type
  final ThemeType? themeType;

// share image file path
  final String? mediaPath;

  MainView(
      {Key? key,
      this.themeType,
      required this.giphyKey,
      required this.onDone,
      this.middleBottomWidget,
      this.colorList,
      this.fileName,
      this.isCustomFontList,
      this.fontFamilyList,
      this.gradientColors,
      this.onBackPress,
      this.onDoneButtonStyle,
      this.editorBackgroundColor,
      this.galleryThumbnailQuality,
      this.centerText,
      this.mediaPath})
      : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// content container key
  final GlobalKey contentKey = GlobalKey();

  ///Editable item
  EditableItem? _activeItem;

  /// Gesture Detector listen changes
  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  /// delete position
  bool _isDeletePosition = false;
  bool _inAction = false;

  /// screen size
  final _screenSize = MediaQueryData.fromWindow(WidgetsBinding.instance.window);

  /// recorder controller
  // final WidgetRecorderController _recorderController =
  //     WidgetRecorderController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var _control = Provider.of<ControlNotifier>(context, listen: false);
      var _tempItemProvider =
          Provider.of<DraggableWidgetNotifier>(context, listen: false);

      /// initialize control variable provider
      _control.giphyKey = widget.giphyKey;
      _control.folderName = widget.fileName ?? "poddin_moment";
      _control.middleBottomWidget = widget.middleBottomWidget;
      _control.isCustomFontList = widget.isCustomFontList ?? false;
      _control.themeType = widget.themeType ?? ThemeType.dark;
      if (widget.mediaPath != null) {
        _control.mediaPath = widget.mediaPath!;
        _tempItemProvider.draggableWidget.insert(
            0,
            EditableItem()
              ..type = ItemType.image
              ..path = widget.mediaPath!
              ..position = const Offset(0.0, 0));
      }
      if (widget.gradientColors != null) {
        _control.gradientColors = widget.gradientColors;
      }
      if (widget.fontFamilyList != null) {
        _control.fontList = widget.fontFamilyList;
      }
      if (widget.colorList != null) {
        _control.colorList = widget.colorList;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _popScope,
      child: Material(
        color: widget.editorBackgroundColor == Colors.transparent
            ? Colors.black
            : widget.editorBackgroundColor ?? Colors.black,
        child: Consumer6<
            ControlNotifier,
            DraggableWidgetNotifier,
            ScrollNotifier,
            GradientNotifier,
            PaintingNotifier,
            TextEditingNotifier>(
          builder: (context, controlNotifier, itemProvider, scrollProvider,
              colorProvider, paintingProvider, editingProvider, child) {
            // return Consumer<RenderingNotifier>(
            //   builder: (_, renderingNotifier, __) {
            return SafeArea(
              child: Stack(
                children: [
                  ScrollablePageView(
                    // scrollPhysics: controlNotifier.mediaPath.isEmpty &&
                    //     itemProvider.draggableWidget.isEmpty &&
                    //     !controlNotifier.isPainting &&
                    //     !controlNotifier.isTextEditing,
                    scrollPhysics: false,
                    pageController: scrollProvider.pageController,
                    gridController: scrollProvider.gridController,
                    mainView: Stack(
                      alignment: Alignment.center,
                      children: [
                        ///gradient container
                        /// this container will contain all widgets(image/texts/draws/sticker)
                        /// wrap this widget with coloredFilter
                        GestureDetector(
                          onScaleStart: _onScaleStart,
                          onScaleUpdate: _onScaleUpdate,
                          onTap: () {
                            controlNotifier.isTextEditing =
                                !controlNotifier.isTextEditing;
                            setState(() {});
                          },
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: SizedBox(
                                width: _screenSize.size.width,
                                height: _screenSize.size.height -
                                    _screenSize.viewPadding.top,
                                // child: ScreenRecorder(
                                //   controller: _recorderController,
                                child: RepaintBoundary(
                                  key: contentKey,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                        gradient:
                                            controlNotifier.mediaPath.isEmpty
                                                ? LinearGradient(
                                                    colors: controlNotifier
                                                            .gradientColors![
                                                        controlNotifier
                                                            .gradientIndex],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : LinearGradient(
                                                    colors: [
                                                      colorProvider.color1,
                                                      colorProvider.color2
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                  )),
                                    child: GestureDetector(
                                      onScaleStart: _onScaleStart,
                                      onScaleUpdate: _onScaleUpdate,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          /// in this case photo view works as a main background container to manage
                                          /// the gestures of all movable items.
                                          PhotoView.customChild(
                                            backgroundDecoration:
                                                const BoxDecoration(
                                                    color: Colors.transparent),
                                            child: Container(),
                                          ),

                                          /// list content items
                                          ...itemProvider.draggableWidget.map(
                                            (editableItem) => DraggableWidget(
                                              context: context,
                                              draggableWidget: editableItem,
                                              onPointerDown: (details) {
                                                _updateItemPosition(
                                                  editableItem,
                                                  details,
                                                );
                                              },
                                              onPointerUp: (details) {
                                                _deleteItemOnCoordinates(
                                                  editableItem,
                                                  details,
                                                );
                                              },
                                              onPointerMove: (details) {
                                                _deletePosition(
                                                  editableItem,
                                                  details,
                                                );
                                              },
                                            ),
                                          ),

                                          /// finger paint
                                          IgnorePointer(
                                            ignoring: true,
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                                child: RepaintBoundary(
                                                  child: SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height -
                                                            132,
                                                    child: StreamBuilder<
                                                        List<PaintingModel>>(
                                                      stream: paintingProvider
                                                          .linesStreamController
                                                          .stream,
                                                      builder:
                                                          (context, snapshot) {
                                                        return CustomPaint(
                                                          painter: Sketcher(
                                                            lines:
                                                                paintingProvider
                                                                    .lines,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // ),
                              ),
                            ),
                          ),
                        ),

                        /// middle text
                        if (itemProvider.draggableWidget.isEmpty &&
                            !controlNotifier.isTextEditing &&
                            paintingProvider.lines.isEmpty)
                          IgnorePointer(
                            ignoring: true,
                            child: Align(
                              alignment: const Alignment(0, -0.1),
                              child: Text(
                                widget.centerText!,
                                style: AppFonts.getTextThemeENUM(
                                        FontType.garamond)
                                    .bodyLarge!
                                    .merge(
                                      TextStyle(
                                        package: 'poddin_moment_designer',
                                        fontWeight: FontWeight.w500,
                                        fontSize: 25,
                                        color: Colors.white.withOpacity(0.5),
                                        shadows: !controlNotifier
                                                .enableTextShadow
                                            ? []
                                            : <Shadow>[
                                                Shadow(
                                                    offset:
                                                        const Offset(1.0, 1.0),
                                                    blurRadius: 3.0,
                                                    color: Colors.black45
                                                        .withOpacity(0.3))
                                              ],
                                      ),
                                    ),
                              ),
                            ),
                          ),

                        /// top tools
                        if (controlNotifier.isTextEditing == false &&
                            controlNotifier.isPainting == false)
                          Align(
                              alignment: Alignment.topCenter,
                              child: TopTools(
                                contentKey: contentKey,
                                context: context,
                                // renderWidget: () => startRecording(
                                //     controlNotifier: controlNotifier,
                                //     renderingNotifier: renderingNotifier,
                                //     saveOnGallery: true),
                              )),

                        /// delete item when the item is in position
                        DeleteItem(
                          activeItem: _activeItem,
                          animationsDuration: const Duration(milliseconds: 300),
                          isDeletePosition: _isDeletePosition,
                        ),

                        /// bottom tools
                        if (controlNotifier.isTextEditing == false &&
                            controlNotifier.isPainting == false)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: BottomTools(
                              contentKey: contentKey,
                              // renderWidget: () => startRecording(
                              //     controlNotifier: controlNotifier,
                              //     renderingNotifier: renderingNotifier,
                              //     saveOnGallery: false),
                              onDone: (bytes) {
                                setState(() {
                                  widget.onDone!(bytes);
                                });
                              },
                              onDoneButtonStyle: widget.onDoneButtonStyle,
                              editorBackgroundColor:
                                  widget.editorBackgroundColor,
                            ),
                          ),

                        /// show text editor
                        Visibility(
                          visible: controlNotifier.isTextEditing,
                          child: TextEditor(
                            context: context,
                          ),
                        ),

                        /// show painting sketch
                        Visibility(
                          visible: controlNotifier.isPainting,
                          child: const Painting(),
                        )
                      ],
                    ),
                    gallery: CameraAwesomeBuilder.awesome(
                      enablePhysicalButton: true,
                      saveConfig: SaveConfig.photo(
                        exifPreferences:
                            ExifPreferences(saveGPSLocation: false),
                        mirrorFrontCamera: true,
                        pathBuilder: (sensors) async {
                          final extDir =
                              await getApplicationDocumentsDirectory();
                          final testDir =
                              await Directory('${extDir.path}/poddin_moment')
                                  .create(recursive: true);
                          // 2.
                          if (sensors.length == 1) {
                            final filePath =
                                '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                            // 3.
                            return SingleCaptureRequest(
                                filePath, sensors.first);
                          } else {
                            // 4.
                            return MultipleCaptureRequest(
                              {
                                for (final sensor in sensors)
                                  sensor:
                                      '${testDir.path}/${sensor.position == SensorPosition.front ? 'front_' : "back_"}${DateTime.now().millisecondsSinceEpoch}.jpg',
                              },
                            );
                          }
                        },
                      ),
                      sensorConfig: SensorConfig.single(
                        flashMode: FlashMode.auto,
                        aspectRatio: CameraAspectRatios.ratio_4_3,
                        sensor: Sensor.position(SensorPosition.front),
                        zoom: 0.0,
                      ),
                      topActionsBuilder: (state) => AwesomeTopActions(
                        state: state,
                        children: [
                          AwesomeFlashButton(state: state),
                          AwesomeZoomSelector(state: state),
                          if (state is PhotoCameraState)
                            AwesomeAspectRatioButton(
                              state: state,
                            ),
                        ],
                      ),
                      middleContentBuilder: (state) {
                        // Use this to add widgets on the middle of the preview
                        return Column(
                          children: [
                            const Spacer(),
                            if (state.captureMode == CaptureMode.photo)
                              AwesomeFilterWidget(
                                state: state,
                                filterListPosition:
                                    FilterListPosition.belowButton,
                              ),
                          ],
                        );
                      },
                      bottomActionsBuilder: (state) => AwesomeBottomActions(
                        state: state,
                        onMediaTap: (mediaCapture) async {
                          HapticFeedback.lightImpact();
                          if (mediaCapture.isPicture) {
                            // Save the last captured photo to device storage
                            var path = mediaCapture.captureRequest.when(
                              single: (p0) => p0.file?.path,
                              // multiple: (p0) => p0.fileBySensor.values.first!.path,
                            );
                            File capturedFile = File(path!);
                            ImageGallerySaver.saveFile(capturedFile.path,
                                name: "poddin_moment_${DateTime.now()}.png");
                          }
                          // then,
                          // open gallery picker
                          final selectedImages = await ImagesPicker.pick(
                            count: 1,
                            pickType: PickType.image,
                            gif: false,
                            quality: 0.8,
                            language: Language.English,
                          );
                          if (selectedImages!.isNotEmpty) {
                            //
                            final path = selectedImages
                                .map((e) => e.path)
                                .toList()
                                .first;
                            // set media path value
                            if (itemProvider.uploadedMedia == 0) {
                              controlNotifier.mediaPath = path;
                              setState(() {});
                            }
                            // add media to view
                            itemProvider
                              ..draggableWidget.insert(
                                  0,
                                  EditableItem()
                                    ..type = ItemType.image
                                    ..path = path
                                    ..position = const Offset(0.0, 0))
                              ..uploadedMedia = 1
                              ..clearMediaPath(controlNotifier);
                            setState(() {});
                            /// scroll to editorView page
                            scrollProvider.pageController.animateToPage(0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.ease);
                          }
                          //
                        },
                      ),
                      filter: AwesomeFilter.LoFi,
                      previewAlignment: Alignment.center,
                      previewFit: CameraPreviewFit.fitWidth,
                      previewPadding: const EdgeInsets.all(20),
                      progressIndicator: const Center(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  //const RenderingIndicator()
                ],
              ),
            );
            //   },
            // );
          },
        ),
      ),
    );
  }

  /// recording and save mp4 widget
  // void startRecording(
  //     {required ControlNotifier controlNotifier,
  //     required RenderingNotifier renderingNotifier,
  //     required bool saveOnGallery}) {
  //   Duration seg = const Duration(seconds: 1);
  //   _recorderController.start(
  //       controlNotifier: controlNotifier, renderingNotifier: renderingNotifier);
  //   Timer.periodic(seg, (timer) async {
  //     if (renderingNotifier.recordingDuration == 0) {
  //       setState(() {
  //         _recorderController.stop(
  //             controlNotifier: controlNotifier,
  //             renderingNotifier: renderingNotifier);
  //         timer.cancel();
  //       });
  //       var path = await _recorderController.export(
  //           controlNotifier: controlNotifier,
  //           renderingNotifier: renderingNotifier);
  //       if (path['success']) {
  //         if (saveOnGallery) {
  //           setState(() {
  //             renderingNotifier.renderState = RenderState.saving;
  //           });
  //           await ImageGallerySaver.saveFile(path['outPath'],
  //                   name: "${DateTime.now()}")
  //               .then((value) {
  //             if (value['isSuccess']) {
  //               debugPrint(value['filePath']);
  //               Fluttertoast.showToast(msg: 'Recording successfully saved');
  //             } else {
  //               debugPrint('Gallery saver error: ${value['errorMessage']}');
  //               Fluttertoast.showToast(msg: 'Gallery saver error');
  //             }
  //           }).whenComplete(() {
  //             setState(() {
  //               controlNotifier.isRenderingWidget = false;
  //               renderingNotifier.renderState = RenderState.none;
  //               renderingNotifier.recordingDuration = 3;
  //             });
  //           });
  //         } else {
  //           setState(() {
  //             controlNotifier.isRenderingWidget = false;
  //             renderingNotifier.renderState = RenderState.none;
  //             renderingNotifier.recordingDuration = 3;
  //             widget.onDone!(path['outPath']);
  //           });
  //         }
  //       } else {
  //         setState(() {
  //           renderingNotifier.renderState = RenderState.none;
  //           Fluttertoast.showToast(msg: 'Something was wrong.');
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         renderingNotifier.recordingDuration--;
  //       });
  //     }
  //   });
  // }

  /// validate pop scope gesture
  Future<bool> _popScope() async {
    final controlNotifier =
        Provider.of<ControlNotifier>(context, listen: false);

    /// change to false text editing
    if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
      return false;
    }

    /// change to false painting
    else if (controlNotifier.isPainting) {
      controlNotifier.isPainting = !controlNotifier.isPainting;
      return false;
    }

    /// show close dialog
    else if (!controlNotifier.isTextEditing && !controlNotifier.isPainting) {
      return widget.onBackPress ??
          exitDialog(
              context: context,
              contentKey: contentKey,
              themeType: widget.themeType!);
    }
    return false;
  }

  /// start item scale
  void _onScaleStart(ScaleStartDetails details) {
    if (_activeItem == null) {
      return;
    }
    _initPos = details.focalPoint;
    _currentPos = _activeItem!.position;
    _currentScale = _activeItem!.scale;
    _currentRotation = _activeItem!.rotation;
  }

  /// update item scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_activeItem == null) {
      return;
    }
    final delta = details.focalPoint - _initPos;

    final left = (delta.dx / _screenSize.size.width) + _currentPos.dx;
    final top = (delta.dy / _screenSize.size.height) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  /// show delete btn when content is within offset region
  void _deletePosition(EditableItem item, PointerMoveEvent details) {
    if (
        //item.type == ItemType.text &&
        item.position.dy >= 0.32 &&
            item.position.dx >= -0.122 &&
            item.position.dx <= 0.122) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    }
    // else if (item.type == ItemType.image &&
    //     item.position.dy >= 0.21 &&
    //     item.position.dx >= -0.122 &&
    //     item.position.dx <= 0.122) {
    //   setState(() {
    //     _isDeletePosition = true;
    //     item.deletePosition = true;
    //   });
    // }
    else {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
    }
  }

  /// delete item widget with offset position
  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var _itemProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false)
            .draggableWidget;
    var widgetProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false);
    var control = Provider.of<ControlNotifier>(context, listen: false);

    _inAction = false;

    if (
        //item.type == ItemType.text &&
        item.position.dy >= 0.21 &&
            item.position.dx >= -0.122 &&
            item.position.dx <= 0.122
        //||
        // item.type == ItemType.image &&
        //     item.position.dy >= 0.21 &&
        //     item.position.dx >= -0.122 &&
        //     item.position.dx <= 0.122)
        ) {
      if (item.type == ItemType.image) {
        widgetProvider
          ..clearMediaPath(control)
          ..uploadedMedia = 0;
        setState(() {});
        //
        if (widgetProvider.uploadedMedia > 1 && control.mediaPath.isNotEmpty) {
          control.mediaPath = '';
          control.gradientIndex += 1;
          setState(() {});
        }
      }
      _itemProvider.removeAt(_itemProvider.indexOf(item));
      setState(() {});
      HapticFeedback.heavyImpact();
    }
    setState(() {
      _activeItem = null;
    });
  }

  /// update item position, scale, rotation
  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }
    _inAction = true;
    _activeItem = item;
    _initPos = details.position;
    _currentPos = item.position;
    _currentScale = item.scale;
    _currentRotation = item.rotation;

    /// set vibrate
    HapticFeedback.lightImpact();
  }
}
