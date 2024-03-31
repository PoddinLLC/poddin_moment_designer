// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_element

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:modal_gif_picker/modal_gif_picker.dart';
import 'package:provider/provider.dart';
// import 'package:poddin_moment_designer/src/domain/models/editable_items.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/draggable_widget_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/text_editing_notifier.dart';
// import 'package:poddin_moment_designer/src/domain/sevices/save_as_image.dart';
import 'package:poddin_moment_designer/src/presentation/utils/Extensions/hexColor.dart';
// import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/animated_onTap_button.dart';
import 'package:poddin_moment_designer/poddin_moment_designer.dart';

import '../../domain/sevices/save_as_image.dart';

/// create item of type GIF
// Future createGiphyItem(
//     {required BuildContext context, required giphyKey}) async {
//   final _editableItem =
//       Provider.of<DraggableWidgetNotifier>(context, listen: false);
//   _editableItem.giphy = await ModalGifPicker.pickModalSheetGif(
//     context: context,
//     apiKey: giphyKey,
//     rating: GiphyRating.r,
//     sticker: true,
//     backDropColor: Colors.black,
//     crossAxisCount: 3,
//     childAspectRatio: 1.2,
//     topDragColor: Colors.white.withOpacity(0.2),
//   );

//   /// create item of type GIF
//   if (_editableItem.giphy != null) {
//     _editableItem.draggableWidget.add(EditableItem()
//       ..type = ItemType.gif
//       //..gif = _editableItem.giphy!
//       ..position = const Offset(0.0, 0.0));
//   }
// }

/// custom exit dialog
Future<bool> exitDialog(
    {required context,
    required contentKey,
    required ThemeType themeType}) async {
  return (await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) => Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetAnimationDuration: const Duration(milliseconds: 300),
          insetAnimationCurve: Curves.ease,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              alignment: Alignment.center,
              // height: 250,
              constraints: const BoxConstraints(maxHeight: 350),
              decoration: BoxDecoration(
                  color: themeType == ThemeType.light
                      ? Colors.white
                      : HexColor.fromHex('#262626'),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: themeType == ThemeType.light
                            ? Colors.black
                            : Colors.white10,
                        offset: const Offset(0, 1),
                        blurRadius: 4),
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Discard Moment?',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: themeType == ThemeType.light
                            ? Colors.black
                            : Colors.white,
                        letterSpacing: 0),
                  ),
                  //
                  const SizedBox(
                    height: 20,
                  ),
                  //
                  Text(
                    "If you go back now, you'll lose all the edits you've made.",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: themeType == ThemeType.light
                            ? Colors.grey
                            : Colors.white54,
                        letterSpacing: 0),
                    textAlign: TextAlign.center,
                  ),
                  //
                  const SizedBox(height: 20),
                  Divider(
                      color: themeType == ThemeType.light
                          ? Colors.black26
                          : Colors.white10),
                  const SizedBox(height: 12),

                  /// discard
                  AnimatedOnTapButton(
                    onTap: () async {
                      _resetDefaults(context: context);
                      Navigator.of(context).pop(true);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Discard',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.redAccent.shade200,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  //
                  const SizedBox(height: 12),
                  Divider(
                      color: themeType == ThemeType.light
                          ? Colors.black26
                          : Colors.white10),
                  const SizedBox(height: 12),
                  // save and exit
                  AnimatedOnTapButton(
                    onTap: () async {
                      /// save image
                      var response = await takePicture(
                          contentKey: contentKey,
                          context: context,
                          saveToGallery: true,
                          fileName: "poddin_moment_draft");
                      if (response) {
                        _dispose(
                            context: context, message: 'Successfully saved');
                      } else {
                        _dispose(
                            context: context, message: 'Unable to save draft');
                      }
                    },
                    child: const Text(
                      'Save Draft',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  //
                  const SizedBox(height: 12),
                  Divider(
                      color: themeType == ThemeType.light
                          ? Colors.black26
                          : Colors.white10),
                  const SizedBox(height: 12),

                  /// cancel
                  AnimatedOnTapButton(
                    onTap: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 15,
                              color: themeType == ThemeType.light
                                  ? Colors.black
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )) ??
      false;
}

_resetDefaults({required BuildContext context}) {
  final _paintingProvider =
      Provider.of<PaintingNotifier>(context, listen: false);
  final _widgetProvider =
      Provider.of<DraggableWidgetNotifier>(context, listen: false);
  final _controlProvider = Provider.of<ControlNotifier>(context, listen: false);
  final _editingProvider =
      Provider.of<TextEditingNotifier>(context, listen: false);
  _paintingProvider.lines.clear();
  _widgetProvider.draggableWidget.clear();
  _widgetProvider.setDefaults();
  _paintingProvider.resetDefaults();
  _editingProvider.setDefaults();
  _controlProvider.mediaPath = '';
}

_dispose({required context, required message}) {
  _resetDefaults(context: context);
  Fluttertoast.showToast(msg: message);
  Navigator.of(context).pop(true);
}
