// ignore_for_file: must_be_immutable, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, deprecated_member_use, unnecessary_import, prefer_const_constructors, unused_import
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:poddin_moment_designer/src/presentation/thumbnail/gallery_thumbnail.dart';
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
import 'package:vs_media_picker/vs_media_picker.dart';
import '../widgets/tool_button.dart';

class MainView extends StatefulWidget {
  /// editor custom font families
  final List<FontType>? fontFamilyList;

  /// editor custom font families package
  final bool? isCustomFontList;

  /// you can pass a folderName where media files will be saved to instead of default folder
  final String? fileName;

  /// giphy api key
  final String? giphyKey;

  /// editor custom color gradients
  final List<List<Color>>? gradientColors;

  /// editor custom logo
  final Widget? middleBottomWidget;

  /// on done action callback
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

  /// Text appearing on center of design screen
  final String? centerText;

  /// theme type
  final ThemeType? themeType;

  /// share image file path
  final String? mediaPath;

  /// initial mode: Camera(1), Editor(0)
  final int? initialMode;

  MainView({
    super.key,
    this.themeType,
    this.giphyKey,
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
    this.mediaPath,
    this.initialMode,
  });

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// content container key
  final GlobalKey contentKey = GlobalKey();

  ///Editable item
  EditableItem? _activeItem;
  final GlobalKey activeItemKey = GlobalKey();

  /// Gesture Detector listen changes
  Offset _initPos = const Offset(0, 0);
  Offset _currentPos = const Offset(0, 0);
  double _currentScale = 1;
  double _currentRotation = 0;

  /// delete position
  bool _isDeletePosition = false;
  bool _inAction = false;

  /// screen size
  Size screenSize = const Size.square(1024);

  /// galleryCam switcher
  bool switchToGallery = false;
  int mediaContent = 0;

  //
  Offset activeOffset = Offset.zero;

  /// recorder controller
  // final WidgetRecorderController _recorderController =
  //     WidgetRecorderController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var _control = Provider.of<ControlNotifier>(context, listen: false);
      var _tempItemProvider =
          Provider.of<DraggableWidgetNotifier>(context, listen: false);
      //
      screenSize = MediaQuery.sizeOf(context);

      /// initialize providers
      _control.giphyKey = widget.giphyKey!;
      _control.initialPage = widget.initialMode ?? 0;
      _control.folderName = widget.fileName ?? "poddin_moment";
      _control.middleBottomWidget = widget.middleBottomWidget;
      _control.isCustomFontList = widget.isCustomFontList ?? false;
      _control.themeType = widget.themeType ?? ThemeType.dark;
      if (widget.mediaPath != null) {
        _control.mediaPath = widget.mediaPath!;
        _tempItemProvider.draggableWidget.add(EditableItem()
          ..type = ItemType.image
          ..path = widget.mediaPath!
          ..scale = 1.2
          ..position = const Offset(0, 0));
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
      //
      if (kDebugMode) debugPrint('Screen size: $screenSize');
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.initialMode!;
    final padding = MediaQuery.paddingOf(context);
    final height = screenSize.height - padding.vertical;
    final width = min(screenSize.width, 500).toDouble();
    //
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
              maintainBottomViewPadding: true,
              child: ScrollablePageView(
                scrollPhysics: false,
                page: page,
                pageController: scrollProvider.pageController,
                gridController: scrollProvider.gridController,
                editor: Stack(
                  alignment: Alignment.center,
                  children: [
                    // gradient container
                    // this container will contain all widgets(image/texts/draws/sticker)
                    // wrap this widget with coloredFilter
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
                        // child: ScreenRecorder(
                        //   controller: _recorderController,
                        child: RepaintBoundary(
                          key: contentKey,
                          child: AnimatedContainer(
                            constraints: BoxConstraints(
                              maxHeight: height,
                              maxWidth: width,
                            ),
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              gradient: controlNotifier.mediaPath.isEmpty
                                  ? LinearGradient(
                                      colors: controlNotifier.gradientColors![
                                          controlNotifier.gradientIndex],
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
                                    ),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                /// list content items
                                ...itemProvider.draggableWidget.map(
                                  (editableItem) => DraggableWidget(
                                    dimension: Size(width, height),
                                    context: context,
                                    draggableWidget: editableItem,
                                    onPointerDown: (details) {
                                      if (kDebugMode) {
                                        debugPrint(
                                            'onPointerDown callback detected');
                                      }
                                      _updateItemPosition(
                                        editableItem,
                                        details,
                                      );
                                    },
                                    onPointerUp: (details) {
                                      if (kDebugMode) {
                                        debugPrint(
                                            'onPointerUp callback detected');
                                      }
                                      _deleteItemOnCoordinates(
                                          editableItem, details);
                                    },
                                    onPointerMove: (details) async {
                                      if (kDebugMode) {
                                        debugPrint(
                                            'onPointerMove callback detected');
                                      }
                                      _deletePosition(editableItem);
                                    },
                                    longPress: () {
                                      if (kDebugMode) {
                                        debugPrint(
                                            'longPress callback detected');
                                      }
                                      reorder(context, editableItem);
                                    },
                                  ),
                                ),

                                /// finger paint
                                IgnorePointer(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      decoration: BoxDecoration(),
                                      child: RepaintBoundary(
                                        child: SizedBox(
                                          width: width,
                                          height: height,
                                          child: StreamBuilder<
                                              List<PaintingModel>>(
                                            stream: paintingProvider
                                                .linesStreamController.stream,
                                            builder: (context, snapshot) {
                                              return CustomPaint(
                                                painter: Sketcher(
                                                  lines: paintingProvider.lines,
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
                        // ),
                      ),
                    ),

                    /// middle text
                    if (itemProvider.draggableWidget.isEmpty &&
                        !controlNotifier.isTextEditing &&
                        paintingProvider.lines.isEmpty)
                      IgnorePointer(
                        child: Align(
                          child: Text(
                            widget.centerText ?? 'Type Something',
                            style: AppFonts.getTextThemeENUM(FontType.garamond)
                                .bodyLarge!
                                .merge(
                                  TextStyle(
                                    package: 'poddin_moment_designer',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 25,
                                    color: Colors.white.withOpacity(0.5),
                                    shadows: !controlNotifier.enableTextShadow
                                        ? []
                                        : <Shadow>[
                                            Shadow(
                                                offset: const Offset(1.0, 1.0),
                                                blurRadius: 3.0,
                                                color: Colors.black45
                                                    .withOpacity(0.3))
                                          ],
                                  ),
                                ),
                          ),
                        ),
                      ),

                    /// Show item alignment indicator
                    if (_activeItem != null && !_isDeletePosition)
                      IgnorePointer(
                        child: SizedBox(
                          width: width,
                          height: height,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Vertical Alignment
                              if (activeOffset.dx == screenSize.width / 2 &&
                                  activeOffset.dy <= screenSize.height)
                                Container(
                                  width: 2,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 0, 76),
                                  ),
                                ),
                              // Horizontal Alignment
                              if (activeOffset.dx <= screenSize.width &&
                                  activeOffset.dy == screenSize.height / 2)
                                Container(
                                  width: width,
                                  height: 2,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 0, 76),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                    /// top tools
                    if (controlNotifier.isTextEditing == false &&
                        controlNotifier.isPainting == false &&
                        _activeItem == null)
                      Align(
                        alignment: Alignment.topCenter,
                        child: TopTools(
                          contentKey: contentKey,
                          context: context,
                          // renderWidget: () => startRecording(
                          //     controlNotifier: controlNotifier,
                          //     renderingNotifier: renderingNotifier,
                          //     saveOnGallery: true),
                        ),
                      ),

                    /// show delete icon when item is within delete region
                    DeleteItem(
                      activeItem: _activeItem,
                      animationsDuration: const Duration(milliseconds: 300),
                      isDeletePosition: _isDeletePosition,
                    ),

                    /// bottom tools
                    if (controlNotifier.isTextEditing == false &&
                        controlNotifier.isPainting == false &&
                        _activeItem == null)
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
                          iosAction: () async {
                            debugPrint('Opened gallery');
                            // switch to gallery view
                            openMediaGallery().then((byte) async {
                              if (byte != null) {
                                /// create file
                                final String dir =
                                    (await getApplicationDocumentsDirectory())
                                        .path;
                                String path =
                                    '$dir/gallery_${DateTime.now().millisecondsSinceEpoch}.png';
                                File capturedFile = File(path);
                                await capturedFile.writeAsBytes(byte);
                                // set media path value
                                if (mediaContent == 0) {
                                  controlNotifier.mediaPath = path;
                                }
                                // add photo to editor view
                                itemProvider.addItem(EditableItem()
                                  ..type = ItemType.image
                                  ..path = path
                                  ..scale = mediaContent < 1 ? 1.2 : 0.8
                                  ..position = const Offset(0, 0));
                                if (mediaContent >= 1) {
                                  controlNotifier.mediaPath = '';
                                }
                                mediaContent++;
                                // nav to editor view
                                // if page = 1, initial view is camera mode
                                // editor page index is 1, camera page index is 0
                                // scrollProvider.pageController.jumpToPage(page);
                                // reset switch variabale
                                // switchToGallery = false;
                              }
                            });
                            //   debugPrint('Opened gallery');
                            //   // setState(() {
                            //   //   switchToGallery = true;
                            //   // });
                            //   // scrollProvider.pageController.jumpToPage(1);
                          },
                          onDoneButtonStyle: widget.onDoneButtonStyle,
                          editorBackgroundColor: widget.editorBackgroundColor,
                        ),
                      ),

                    /// show text editor
                    Visibility(
                      visible: controlNotifier.isTextEditing,
                      child: TextEditor(context: context),
                    ),

                    /// show painting sketch
                    Visibility(
                      visible: controlNotifier.isPainting,
                      child: const Painting(),
                    )
                  ],
                ),
                // Show camera and gallery
                camera: Stack(
                  children: [
                    // Camera
                    if (!switchToGallery && !kIsWeb && Platform.isAndroid)
                      CameraAwesomeBuilder.awesome(
                        enablePhysicalButton: true,
                        saveConfig: SaveConfig.photo(
                          mirrorFrontCamera: true,
                          pathBuilder: (sensors) async {
                            final extDir =
                                await getApplicationDocumentsDirectory();
                            final testDir =
                                await Directory('${extDir.path}/moments')
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
                          aspectRatio: CameraAspectRatios.ratio_16_9,
                          sensor: Sensor.position(SensorPosition.front),
                          flashMode: FlashMode.none,
                        ),
                        topActionsBuilder: (state) => AwesomeTopActions(
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, top: 10),
                          state: state,
                          children: [
                            AwesomeOrientedWidget(
                              child: () {
                                if (page == 0) {
                                  // if default view is Editor mode
                                  return GestureDetector(
                                    onTap: () {
                                      // nav to editor view
                                      // page == 0 (initial view is Editor mode)
                                      // editor index is 0, camera index is 1
                                      scrollProvider.pageController
                                          .animateToPage(0,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.ease);
                                    },
                                    child: const AwesomeCircleWidget.icon(
                                      icon: Icons.arrow_back_ios_new_rounded,
                                    ),
                                  );
                                } else {
                                  // if default view is Camera mode
                                  return GestureDetector(
                                    onTap: () {
                                      // nav to editor view
                                      // page == 1 (initial view is Camera mode)
                                      // editor index is 1, camera index is 0
                                      scrollProvider.pageController
                                          .animateToPage(1,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.ease);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD91C54),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        child: const ImageIcon(
                                          AssetImage('assets/icons/text.png',
                                              package:
                                                  'poddin_moment_designer'),
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }(),
                            ),
                            // flash light btn
                            AwesomeFlashButton(state: state),
                            // gallery btn
                            AwesomeOrientedWidget(
                              child: GestureDetector(
                                onTap: () {
                                  // switch to gallery view
                                  setState(() {
                                    switchToGallery = true;
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child:
                                        GalleryThumbnail(height: 40, width: 40),
                                  ),
                                ),
                              ),
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
                                    filterListPadding:
                                        const EdgeInsets.only(bottom: 10)),
                            ],
                          );
                        },
                        bottomActionsBuilder: (state) => AwesomeBottomActions(
                          onMediaTap: (mediaCapture) => onPreviewTap(
                            mediaCapture,
                            controlNotifier,
                            itemProvider,
                            scrollProvider,
                            page,
                          ),
                          state: state,
                          left: AwesomeCameraSwitchButton(
                            state: state,
                            iconBuilder: () {
                              return const AwesomeCircleWidget.icon(
                                icon: Icons.cameraswitch,
                                scale: 1.2,
                              );
                            },
                          ),
                        ),
                        theme: AwesomeTheme(
                          bottomActionsBackgroundColor: Colors.black12,
                          buttonTheme: AwesomeButtonTheme(
                            padding: const EdgeInsets.all(10),
                            iconSize: 20,
                            buttonBuilder: (child, onTap) {
                              return SizedBox(
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    child: GestureDetector(
                                      onTap: onTap,
                                      child: child,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        defaultFilter: AwesomeFilter.Juno,
                        progressIndicator: const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    // Gallery
                    //
                    // if (switchToGallery)
                    // Visibility(
                    //   child: VSMediaPicker(
                    //     maxPickImages: 1,
                    //     gridViewController: scrollProvider.gridController,
                    //     thumbnailQuality: 300,
                    //     singlePick: true,
                    //     onlyImages: true,
                    //     selectedBackgroundColor: const Color(0xFFD91C54),
                    //     imageBackgroundColor: Colors.black,
                    //     appBarIconColor: Colors.white,
                    //     albumBackGroundColor: Colors.black,
                    //     albumDividerColor: Color(0xEE272727),
                    //     gridViewBackgroundColor: Colors.black,
                    //     childAspectRatio: 0.6,
                    //     crossAxisCount: 3,
                    //     appBarHeight: 50,
                    //     gridPadding: EdgeInsets.zero,
                    //     appBarColor:
                    //         widget.editorBackgroundColor ?? Colors.black,
                    //     pathList: (path) {
                    //       if (path.isNotEmpty) {
                    //         // set media path value
                    //         if (mediaContent == 0) {
                    //           controlNotifier.mediaPath = path[0].path!;
                    //         }
                    //         // add photo to editor view
                    //         itemProvider.addItem(EditableItem()
                    //           ..type = ItemType.image
                    //           ..path = path[0].path!
                    //           ..scale = mediaContent < 1 ? 1.2 : 0.8
                    //           ..position = const Offset(0, 0));
                    //         if (mediaContent >= 1) {
                    //           controlNotifier.mediaPath = '';
                    //         }
                    //         mediaContent++;
                    //         // nav to editor view
                    //         // if page = 1, initial view is camera mode
                    //         // editor page index is 1, camera page index is 0
                    //         scrollProvider.pageController.jumpToPage(page);
                    //         // reset switch variabale
                    //         switchToGallery = false;
                    //       }
                    //     },
                    //     appBarLeadingWidget: Align(
                    //       alignment: Alignment.centerRight,
                    //       child: Padding(
                    //         padding:
                    //             const EdgeInsets.only(bottom: 5, right: 15),
                    //         child: ToolButton(
                    //           topPadding: false,
                    //           padding: EdgeInsets.zero,
                    //           borderHide: true,
                    //           backGroundColor: Colors.black,
                    //           onTap: () {
                    //             if (Platform.isIOS) {
                    //               scrollProvider.pageController.jumpToPage(0);
                    //             } else {
                    //               setState(() => switchToGallery = false);
                    //             }
                    //           },
                    //           child: const Icon(
                    //             Icons.close,
                    //             size: 28,
                    //             color: Colors.white,
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // AlbumImagePicker(
                    //   onSelected: (images) async {
                    //     final selected = await images.first.file;
                    //     final path = selected?.path;
                    //     if (path != null) {
                    //       // set media path value
                    //       if (mediaContent == 0) {
                    //         controlNotifier.mediaPath = path;
                    //         setState(() {});
                    //       }
                    //       // add photo to editor view
                    //       itemProvider.addItem(EditableItem()
                    //         ..type = ItemType.image
                    //         ..path = path
                    //         ..scale = mediaContent < 1 ? 1.2 : 0.8
                    //         ..position = const Offset(0, 0));
                    //       if (mediaContent >= 1) {
                    //         controlNotifier.mediaPath = '';
                    //       }
                    //       mediaContent++;
                    //       // nav to editor view
                    //       // if page = 1, initial view is camera mode
                    //       // editor page index is 1, camera page index is 0
                    //       scrollProvider.pageController.jumpToPage(page);
                    //       // reset switch variabale
                    //       switchToGallery = false;
                    //     }
                    //   },
                    //   selectionBuilder: (_, selected, index) {
                    //     if (selected) {
                    //       return CircleAvatar(
                    //         backgroundColor: const Color(0xFFD91C54),
                    //         radius: 10,
                    //         child: Text(
                    //           '${index + 1}',
                    //           style: const TextStyle(
                    //               fontSize: 10,
                    //               height: 1.4,
                    //               color: Colors.white),
                    //         ),
                    //       );
                    //     }
                    //     return const SizedBox();
                    //   },
                    //   crossAxisCount: 3,
                    //   maxSelection: 1,
                    //   albumBackGroundColor: Colors.black87,
                    //   itemBackgroundColor: Colors.black87,
                    //   appBarColor: Colors.black,
                    //   albumTextStyle:
                    //       const TextStyle(color: Colors.white, fontSize: 14),
                    //   albumSubTextStyle:
                    //       const TextStyle(color: Colors.grey, fontSize: 10),
                    //   albumDividerColor: Colors.black54,
                    //   listBackgroundColor: Colors.black87,
                    //   childAspectRatio: 0.6,
                    //   type: AlbumType.image,
                    //   closeWidget: CloseButton(
                    //     color: Colors.white,
                    //     onPressed: () {
                    //       if (Platform.isIOS) {
                    //         scrollProvider.pageController.jumpToPage(0);
                    //       } else {
                    //         setState(() => switchToGallery = false);
                    //       }
                    //     },
                    //   ),
                    //   thumbnailQuality: 300,
                    // ),
                  ],
                ),
              ),
              //
              //const RenderingIndicator()
            );
            //   },
            // );
          },
        ),
      ),
    );
  }

  /// Pop gallery
  Future<Uint8List?> openMediaGallery() async {
    //
    const AlbumSetting albumSetting = AlbumSetting(
      fetchResults: {
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumFavorites,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.album,
          subtype: PHAssetCollectionSubtype.albumRegular,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumSelfPortraits,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.smartAlbum,
          subtype: PHAssetCollectionSubtype.smartAlbumPanoramas,
        ),
        PHFetchResult(
          type: PHAssetCollectionType.album,
          subtype: PHAssetCollectionSubtype.albumImported,
        ),
      },
    );
    //
    const SelectionSetting selectionSetting =
        SelectionSetting(min: 1, max: 1, unselectOnReachingMax: true);
    //
    const DismissSetting dismissSetting =
        DismissSetting(enabled: true, allowSwipe: true);
    //
    final ThemeSetting themeSetting = ThemeSetting(
      backgroundColor: Colors.black,
      selectionFillColor: Color(0xFFD91C54),
      selectionStrokeColor: Colors.white,
      previewSubtitleAttributes: const TitleAttribute(
          fontSize: 12.0, foregroundColor: Color.fromARGB(255, 178, 178, 178)),
      previewTitleAttributes: TitleAttribute(
        foregroundColor: Colors.white,
      ),
      albumTitleAttributes: TitleAttribute(
        foregroundColor: Colors.white,
      ),
    );
    //
    const ListSetting listSetting = ListSetting(spacing: 3.0, cellsPerRow: 4);
    //
    final CupertinoSettings iosSettings = CupertinoSettings(
      fetch: const FetchSetting(album: albumSetting),
      theme: themeSetting,
      selection: selectionSetting,
      dismiss: dismissSetting,
      list: listSetting,
      previewEnabled: false,
    );
    //

    final media = await MultiImagePicker.pickImages(
      selectedAssets: [],
      iosOptions: IOSOptions(
        settings: iosSettings,
        doneButton: UIBarButtonItem(
            title: 'Confirm',
            tintColor: const Color.fromARGB(255, 102, 194, 105)),
        cancelButton: UIBarButtonItem(
            title: 'Cancel', tintColor: const Color.fromARGB(255, 224, 55, 43)),
        albumButtonColor: Color(0xFFD91C54),
      ),
      androidOptions: const AndroidOptions(
        maxImages: 1,
        hasCameraInPickerPage: false,
        startInAllView: true,
        lightStatusBar: false,
        textOnNothingSelected: 'Choose a photo',
        autoCloseOnSelectionLimit: true,
        actionBarTitle: "Gallery",
        allViewTitle: "All",
        useDetailsView: false,
        exceptMimeType: {MimeType.PNG, MimeType.JPEG},
        actionBarColor: Colors.black,
        statusBarColor: Colors.black,
        actionBarTitleColor: Colors.white,
        selectCircleStrokeColor: Color(0xFFD91C54),
      ),
    );
    if (kDebugMode) {
      print(media.map((e) async {
        final data = await e.getByteData();
        return data.buffer.asUint8List();
      }).toList());
    }
    if (media.isNotEmpty) {
      final data = await media.first.getByteData(quality: 80);
      return data.buffer.asUint8List();
    }
    return null;
  }

  /// get active item offet
  void currentItemOffset(ScaleUpdateDetails details) async {
    // final RenderBox renderBox =
    //     activeItemKey.currentContext!.findRenderObject()! as RenderBox;
    // final size = renderBox.size;
    final position = details.focalPoint; //renderBox.localToGlobal(Offset.zero);
    // Offset myOffset =
    //     Offset(position.dx / size.width, position.dy / size.height);
    setState(() {
      activeOffset = position;
    });
    // Fluttertoast.showToast(
    //     msg:
    //         'Content Offset: $position, Active Offset: ${_activeItem?.position}',
    //     gravity: ToastGravity.TOP);
    if (kDebugMode) {
      debugPrint('''Content Offset: $position\nRaw position: $position''');
    }
  }

  /// Preview tap action
  onPreviewTap(
    MediaCapture? media,
    ControlNotifier controlNotifier,
    DraggableWidgetNotifier itemProvider,
    ScrollNotifier scrollProvider,
    int page,
  ) async {
    // Get the last captured photo
    final path = media!.captureRequest.when(
      single: (p0) => p0.file!.path,
    );
    // set media path value
    if (mediaContent == 0) {
      controlNotifier.mediaPath = path;
    }
    // add image to editor
    itemProvider.addItem(EditableItem()
      ..type = ItemType.image
      ..path = path
      ..scale = mediaContent < 1 ? 1.2 : 0.8
      ..position = const Offset(0, 0));
    //
    if (mediaContent >= 1) {
      controlNotifier.mediaPath = '';
    }
    //
    mediaContent++;
    // nav to editor view
    // if page = 1, initial view is camera mode
    // editor page index is 1, camera page index is 0
    scrollProvider.pageController.jumpToPage(page);
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
  //                if (kDebugMode) debugPrint(value['filePath']);
  //               Fluttertoast.showToast(msg: 'Recording successfully saved');
  //             } else {
  //                if (kDebugMode) debugPrint('Gallery saver error: ${value['errorMessage']}');
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
    var content = Provider.of<DraggableWidgetNotifier>(context, listen: false);

    /// Exit page if there's no content in the editor
    if (content.draggableWidget.isEmpty) {
      return true;
    }

    /// change text editing state to false
    else if (controlNotifier.isTextEditing) {
      controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
      return false;
    }

    /// change painting state to false
    else if (controlNotifier.isPainting) {
      controlNotifier.isPainting = !controlNotifier.isPainting;
      return false;
    }

    /// show close dialog
    else if (!controlNotifier.isTextEditing &&
        !controlNotifier.isPainting &&
        content.draggableWidget.isNotEmpty) {
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
    if (kDebugMode) debugPrint('onScaleStart callback detected');

    setState(() {
      _initPos = details.focalPoint;
      _currentPos = _activeItem!.position;
      _currentScale = _activeItem!.scale;
      _currentRotation = _activeItem!.rotation;
    });
  }

  /// update item scale
  void _onScaleUpdate(ScaleUpdateDetails details) {
    if (_activeItem == null) {
      return;
    }
    if (kDebugMode) debugPrint('onScaleUpdate callback detected');
    currentItemOffset(details);
    final padding = MediaQuery.paddingOf(context);
    final height = screenSize.height - padding.vertical;
    final width = min(screenSize.width, 500).toDouble();
    //
    final position = details.focalPoint - _initPos;

    final left = (position.dx / width) + _currentPos.dx;
    final top = (position.dy / height) + _currentPos.dy;

    setState(() {
      _activeItem!.position = Offset(left, top);
      _activeItem!.rotation = details.rotation + _currentRotation;
      _activeItem!.scale = details.scale * _currentScale;
    });
  }

  /// update content deletePosition when dragged to delete region
  void _deletePosition(EditableItem item) {
    if (item.position.dy >= 0.29 &&
        item.position.dx >= -0.12 &&
        item.position.dx <= 0.12) {
      setState(() {
        _isDeletePosition = true;
        item.deletePosition = true;
      });
    } else {
      setState(() {
        _isDeletePosition = false;
        item.deletePosition = false;
      });
    }
  }

  /// remove item when it's in the delete region
  void _deleteItemOnCoordinates(EditableItem item, PointerUpEvent details) {
    var _itemProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false);
    var control = Provider.of<ControlNotifier>(context, listen: false);
    _inAction = false;

    if (item.position.dy >= 0.29 &&
        item.position.dx >= -0.12 &&
        item.position.dx <= 0.12) {
      if (item.type == ItemType.image) {
        if (mediaContent >= 1) {
          control.mediaPath = '';
        }
        //
        mediaContent--;
      }
      //
      _itemProvider.removeItem(item);
      HapticFeedback.lightImpact();
    }
    //
    setState(() {
      _activeItem = null;
    });
  }

  /// update item position, scale, rotation
  void _updateItemPosition(EditableItem item, PointerDownEvent details) {
    if (_inAction) {
      return;
    }
    if (kDebugMode) debugPrint('Update item position callback detected!');

    setState(() {
      _inAction = true;
      _activeItem = item;
      _initPos = details.position;
      _currentPos = item.position;
      _currentScale = item.scale;
      _currentRotation = item.rotation;
    });
    // set vibrate
    HapticFeedback.lightImpact();
  }

  /// onLongPress content
  Future<void> reorder(
    BuildContext context,
    EditableItem item,
  ) async {
    final _itemProvider =
        Provider.of<DraggableWidgetNotifier>(this.context, listen: false);
    if (_itemProvider.draggableWidget.length > 1) {
      _itemProvider.removeItem(item);
      await Future.delayed(const Duration(milliseconds: 100));
      _itemProvider.insertAt(
          _itemProvider.draggableWidget
                  .indexOf(_itemProvider.draggableWidget.last) +
              1,
          item);
      // vibrate
      HapticFeedback.lightImpact();
    }
  }
}
