// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_local_variable
import 'dart:io';
import 'package:align_positioned/align_positioned.dart';
import 'package:flutter/foundation.dart';
// import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:poddin_moment_designer/src/presentation/text_editor_view/utils/rounded_text.dart';
// import 'package:modal_gif_picker/modal_gif_picker.dart';
import 'package:provider/provider.dart';
import 'package:poddin_moment_designer/src/domain/models/editable_items.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/gradient_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/font_family.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';
// import 'package:poddin_moment_designer/src/presentation/utils/constants/text_animation_type.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/animated_onTap_button.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/file_image_bg.dart';

class DraggableWidget extends StatelessWidget {
  final EditableItem draggableWidget;
  final Function(PointerDownEvent)? onPointerDown;
  final Function(PointerUpEvent)? onPointerUp;
  final Function(PointerMoveEvent)? onPointerMove;
  final void Function()? longPress;
  final Size? dimension;
  final BuildContext context;
  const DraggableWidget({
    super.key,
    required this.context,
    required this.draggableWidget,
    this.dimension,
    this.onPointerDown,
    this.onPointerUp,
    this.onPointerMove,
    this.longPress,
  });

  @override
  Widget build(BuildContext context) {
    final _colorProvider =
        Provider.of<GradientNotifier>(this.context, listen: false);
    final _controlProvider =
        Provider.of<ControlNotifier>(this.context, listen: false);
    Widget overlayWidget;

    switch (draggableWidget.type) {
      case ItemType.text:
        overlayWidget = Container(
          constraints: BoxConstraints(
            minHeight: 50,
            minWidth: 50,
            maxWidth: dimension!.width - 100,
          ),
          width: draggableWidget.deletePosition ? 0 : null,
          height: draggableWidget.deletePosition ? 0 : null,
          child: AnimatedOnTapButton(
            onTap: () => _onTap(context, draggableWidget, _controlProvider),
            onLongPress: longPress,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // show text with or without background
                RoundedBackgroundText(
                  draggableWidget.text,
                  backgroundColor: draggableWidget.backGroundColor,
                  color: draggableWidget.textColor,
                  textAlign: draggableWidget.textAlign,
                  style: AppFonts.getTextThemeENUM(_controlProvider
                          .fontList![draggableWidget.fontFamily])
                      .bodyLarge!
                      .merge(
                        TextStyle(
                          color: draggableWidget.textColor,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
                          fontSize: draggableWidget.deletePosition
                              ? 0
                              : draggableWidget.fontSize,
                          shadows: !_controlProvider.enableTextShadow
                              ? []
                              : <Shadow>[
                                  Shadow(
                                      offset: const Offset(0, 0),
                                      blurRadius: 3.0,
                                      color: draggableWidget.textColor ==
                                              Colors.black
                                          ? Colors.white54
                                          : Colors.black)
                                ],
                        ),
                      ),
                  maxLines: null,
                ),
                // show this when text has background
                // Center(
                //   child: text(
                //     background: true,
                //     paintingStyle: PaintingStyle.fill,
                //     controlNotifier: _controlProvider,
                //   ),
                // ),
                // // add stroke when text has background
                // IgnorePointer(
                //   ignoring: true,
                //   child: Center(
                //     child: text(
                //       background: true,
                //       paintingStyle: PaintingStyle.stroke,
                //       controlNotifier: _controlProvider,
                //     ),
                //   ),
                // ),
                // // default text displayed
                // Padding(
                //   padding: const EdgeInsets.only(right: 0, top: 0),
                //   child: Stack(
                //     children: [
                //       Center(
                //         child: text(
                //           paintingStyle: PaintingStyle.fill,
                //           controlNotifier: _controlProvider,
                //         ),
                //       ),
                //     ],
                //   ),
                // )
              ],
            ),
          ),
        );
        break;

      /// image [file_image_gb.dart]
      case ItemType.image:
        overlayWidget = AnimatedOnTapButton(
          onLongPress: longPress,
          onTap: () {},
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: dimension!.height * draggableWidget.scale,
                maxWidth: dimension!.width * draggableWidget.scale,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              width: draggableWidget.deletePosition ? 0 : null,
              height: draggableWidget.deletePosition ? 0 : null,
              child: FileImageBG(
                dimension: dimension,
                scale: draggableWidget.scale,
                filePath: File(draggableWidget.path),
              ),
            ),
          ),
        );
        break;
      case ItemType.gif:
        overlayWidget = SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// create Gif widget
              Center(
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.transparent),
                  // child: GiphyRenderImage.original(gif: draggableWidget.gif),
                ),
              ),
            ],
          ),
        );
        break;

      case ItemType.video:
        overlayWidget = const Center();
    }

    /// set widget data position on main screen
    return AnimatedAlignPositioned(
      duration: const Duration(milliseconds: 50),
      dy: (draggableWidget.deletePosition
          ? _deleteTopOffset(dimension)
          : (draggableWidget.position.dy * dimension!.height)),
      dx: (draggableWidget.deletePosition
          ? 0
          : (draggableWidget.position.dx * dimension!.width)),
      alignment: Alignment.center,
      child: Transform.scale(
        scale: draggableWidget.deletePosition
            ? _deleteScale()
            : draggableWidget.scale,
        child: Transform.rotate(
          angle: draggableWidget.rotation,
          child: Listener(
            onPointerDown: onPointerDown,
            onPointerUp: onPointerUp,
            onPointerMove: onPointerMove,
            child: overlayWidget, // show widget
          ),
        ),
      ),
    );
  }

  /// text widget
  Widget text(
      {required ControlNotifier controlNotifier,
      required PaintingStyle paintingStyle,
      bool background = false}) {
    // if (draggableWidget.animationType == TextAnimationType.none) {
    return Text(
      draggableWidget.text,
      textAlign: draggableWidget.textAlign,
      style: _textStyle(
          controlNotifier: controlNotifier,
          paintingStyle: paintingStyle,
          background: background),
    );
    // }
    //  else {
    // return DefaultTextStyle(
    //   style: _textStyle(
    //       controlNotifier: controlNotifier,
    //       paintingStyle: paintingStyle,
    //       background: background),
    //   child: AnimatedTextKit(
    //     repeatForever: true,
    //     onTap: () => _onTap(context, draggableWidget, controlNotifier),
    //     animatedTexts: [
    //       if (draggableWidget.animationType == TextAnimationType.scale)
    //         ScaleAnimatedText(draggableWidget.text,
    //             duration: const Duration(milliseconds: 1200)),
    //       if (draggableWidget.animationType == TextAnimationType.fade)
    //         ...draggableWidget.textList.map((item) => FadeAnimatedText(item,
    //             duration: const Duration(milliseconds: 1200))),
    //       if (draggableWidget.animationType == TextAnimationType.typer)
    //         TyperAnimatedText(draggableWidget.text,
    //             speed: const Duration(milliseconds: 500)),
    //       if (draggableWidget.animationType == TextAnimationType.typeWriter)
    //         TypewriterAnimatedText(
    //           draggableWidget.text,
    //           speed: const Duration(milliseconds: 500),
    //         ),
    //       if (draggableWidget.animationType == TextAnimationType.wavy)
    //         WavyAnimatedText(
    //           draggableWidget.text,
    //           speed: const Duration(milliseconds: 500),
    //         ),
    //       if (draggableWidget.animationType == TextAnimationType.flicker)
    //         FlickerAnimatedText(
    //           draggableWidget.text,
    //           speed: const Duration(milliseconds: 1200),
    //         ),
    //     ],
    //   ),
    // );
    // }
  }

  _textStyle({
    required ControlNotifier controlNotifier,
    required PaintingStyle paintingStyle,
    bool background = false,
  }) {
    return AppFonts.getTextThemeENUM(
            controlNotifier.fontList![draggableWidget.fontFamily])
        .bodyLarge!
        .merge(
          TextStyle(
            fontWeight: FontWeight.w500,
            shadows: !controlNotifier.enableTextShadow
                ? []
                : <Shadow>[
                    Shadow(
                        offset: const Offset(0, 0),
                        blurRadius: 3.0,
                        color: draggableWidget.textColor == Colors.black
                            ? Colors.white54
                            : Colors.black)
                  ],
          ),
        )
        .copyWith(
          color: background ? Colors.transparent : draggableWidget.textColor,
          fontSize:
              draggableWidget.deletePosition ? 0 : draggableWidget.fontSize,
          background: Paint()
            ..strokeWidth = draggableWidget.deletePosition ? 0 : 20
            ..color = draggableWidget.backGroundColor
            ..style = paintingStyle
            ..strokeJoin = StrokeJoin.round
            ..filterQuality = FilterQuality.high
            ..strokeCap = StrokeCap.round
            ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1),
        );
  }

  _deleteTopOffset(size) {
    double top = 0.0;
    if (draggableWidget.type == ItemType.text ||
        draggableWidget.type == ItemType.image) {
      top = size.width / 1.3;
      if (kDebugMode) debugPrint('{"Top offset: $top"}');
    }
    return top;
  }

  _deleteScale() {
    double scale = 0.0;
    if (draggableWidget.type == ItemType.text) {
      scale = 0.4;
    } else if (draggableWidget.type == ItemType.image) {
      scale = 0.2;
    }
    return scale;
  }

  /// onTap text
  void _onTap(
    BuildContext context,
    EditableItem item,
    ControlNotifier controlNotifier,
  ) {
    var _editorProvider =
        Provider.of<TextEditingNotifier>(this.context, listen: false);
    var _itemProvider =
        Provider.of<DraggableWidgetNotifier>(this.context, listen: false);

    /// load text attributes
    _editorProvider.textController.text = item.text.trim();
    _editorProvider.text = item.text.trim();
    _editorProvider.fontFamilyIndex = item.fontFamily;
    _editorProvider.textSize = item.fontSize;
    _editorProvider.backGroundColor = item.backGroundColor;
    _editorProvider.textAlign = item.textAlign;
    _editorProvider.textColor =
        controlNotifier.colorList!.indexOf(item.textColor);
    _editorProvider.animationType = item.animationType;
    _editorProvider.fontAnimationIndex = item.fontAnimationIndex;
    _editorProvider.textPosition = item.position;
    _editorProvider.fontFamilyController = PageController(
      initialPage: item.fontFamily,
      viewportFraction: .1,
    );
    // remove text widget
    _itemProvider.removeItem(item);
    // create new text item
    controlNotifier.isTextEditing = !controlNotifier.isTextEditing;
  }
}
