// ignore_for_file: must_be_immutable, library_private_types_in_public_api, no_leading_underscores_for_local_identifiers, deprecated_member_use, unnecessary_import, prefer_const_constructors, unused_import
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
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
      if (kDebugMode) debugPrint('Main view screen size: $screenSize');
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
                                maxHeight: height, maxWidth: width),
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
                                    key: ValueKey(
                                        '${editableItem.type.name}_widget_${editableItem.type == ItemType.text ? editableItem.text.substring(0, editableItem.text.length - 100 >= 0 ? 100 : editableItem.text.length) : editableItem.path.split('/').last}'),
                                    dimension: Size(width, height),
                                    context: context,
                                    draggableWidget: editableItem,
                                    onPointerDown: (details) {
                                      if (kDebugMode) {
                                        debugPrint('onPointerDown detected');
                                      }
                                      _updateItemPosition(
                                          editableItem, details);
                                    },
                                    onPointerUp: (details) {
                                      if (kDebugMode) {
                                        debugPrint('onPointerUp detected');
                                      }
                                      _deleteItemOnCoordinates(
                                          editableItem, details);
                                    },
                                    onPointerMove: (details) async {
                                      if (kDebugMode) {
                                        debugPrint('onPointerMove detected');
                                      }
                                      _deletePosition(editableItem);
                                    },
                                    doubleTap: () {
                                      // vibrate
                                      HapticFeedback.lightImpact();
                                      if (kDebugMode) {
                                        debugPrint('doubleTap detected');
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
                              if (_activeItem!.position.direction ==
                                      1.5707963267948966 ||
                                  _activeItem!.position.direction ==
                                      -1.5707963267948966)
                                Container(
                                  width: 1,
                                  height: height,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 66, 123),
                                  ),
                                ),
                              // Horizontal Alignment
                              if (_activeItem!.position == Offset(0.0, 0.0))
                                Container(
                                  width: width,
                                  height: 1,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 66, 123),
                                  ),
                                ),
                            ],
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
                          iosAction: () async {
                            debugPrint('Opened gallery');
                            // switch to gallery view
                            openMediaGallery().then((path) async {
                              if (path != null) {
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
                              }
                            });
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
                // Show camera
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
                                            color: Colors.white, width: 1.5),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: const ImageIcon(
                                            AssetImage('assets/icons/text.png',
                                                package:
                                                    'poddin_moment_designer'),
                                            color: Colors.white,
                                            size: 18),
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
                                  openMediaGallery().then((path) async {
                                    if (path != null) {
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
                                      scrollProvider.pageController
                                          .jumpToPage(page);
                                    }
                                  });
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
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
                              page),
                          state: state,
                          left: AwesomeCameraSwitchButton(
                            state: state,
                            iconBuilder: () {
                              return const AwesomeCircleWidget.icon(
                                  icon: Icons.cameraswitch, scale: 1.2);
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
                                        onTap: onTap, child: child),
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
                                strokeWidth: 2),
                          ),
                        ),
                      ),
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
  Future<String?> openMediaGallery() async {
    final media = await AssetPicker.pickAssets(
      context,
      permissionRequestOption: PermissionRequestOption(),
      pickerConfig: AssetPickerConfig(
        maxAssets: 1,
        requestType: RequestType.image,
        keepScrollOffset: true,
        sortPathsByModifiedDate: true,
        gridCount: 3,
        pageSize: 90,
        specialPickerType: SpecialPickerType.noPreview,
        textDelegate: EnglishAssetPickerTextDelegate(),
        pickerTheme: ThemeData.dark(),
        loadingIndicatorBuilder: (context, isAssetsEmpty) {
          if (isAssetsEmpty) {
            return Center(
              child: Text(
                'No photos found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          return SizedBox.square(
            dimension: 45,
            child: CircularProgressIndicator.adaptive(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              backgroundColor: Colors.transparent,
              strokeWidth: 1.5,
            ),
          );
        },
      ),
    );
    debugPrint('Selected: ${media?.length}');
    if (media != null && media.isNotEmpty) {
      final file = await media.first.file;
      debugPrint(file!.path);
      return file.path;
    }
    return null;
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
    else if (content.draggableWidget.isNotEmpty) {
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
    // if (kDebugMode) debugPrint('onScaleStart callback detected');

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
    if (kDebugMode) debugPrint('onScaleUpdate detected');
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
    debugPrint(
        'Item position: ${_activeItem!.position} || Item direction: ${_activeItem!.position.direction}');
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
    //if (kDebugMode) debugPrint('Update item position callback detected!');

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
    EditableItem widget,
  ) async {
    final _itemProvider =
        Provider.of<DraggableWidgetNotifier>(context, listen: false);
    if (_itemProvider.draggableWidget.length > 1) {
      // widget index
      final index = _itemProvider.draggableWidget.indexOf(widget);
      // index of widget at end of the list
      final lastIndex = _itemProvider.draggableWidget.length - 1;
      // widget not found
      if (index == -1 || index > lastIndex) return;
      // remove widget from the list
      _itemProvider.removeItem(widget);
      // insert widget to a new position backward
      if (index == lastIndex) {
        _itemProvider.insertAt(index - 1, widget);
      }
      // insert widget to a new position forward
      else if (index < lastIndex) {
        _itemProvider.insertAt(index + 1, widget);
      }
      // setState(() {});
    }
  }
}
