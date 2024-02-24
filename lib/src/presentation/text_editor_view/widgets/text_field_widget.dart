// ignore_for_file: unrelated_type_equality_checks, no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:poddin_moment_designer/src/presentation/text_editor_view/utils/rouded_text_field.dart';
import 'package:provider/provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/text_editing_notifier.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/font_family.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var _size = MediaQuery.of(context).size;
    FocusNode _textNode = FocusNode();
    return Consumer2<TextEditingNotifier, ControlNotifier>(
      builder: (context, editorNotifier, controlNotifier, child) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _size.width - 100,
            ),
            child: RoundedBackgroundTextField(
              focusNode: _textNode,
              autofocus: true,
              textInputAction: TextInputAction.newline,
              controller: editorNotifier.textController,
              style: AppFonts.getTextThemeENUM(
                      controlNotifier.fontList![editorNotifier.fontFamilyIndex])
                  .bodyLarge!
                  .copyWith(
                    color: controlNotifier.colorList![editorNotifier.textColor],
                    height: 1.4,
                    fontSize: editorNotifier.textSize,
                  ),
              backgroundColor: editorNotifier.backGroundColor,
              textAlign: editorNotifier.textAlign,
              cursorColor: controlNotifier.colorList![editorNotifier.textColor],
              keyboardType: TextInputType.multiline,
              onChanged: (value) {
                editorNotifier.text = value;
              },
            ),
          ),
        );
      },
    );
  }

  Widget textField({
    required TextEditingNotifier editorNotifier,
    required FocusNode textNode,
    required ControlNotifier controlNotifier,
    required PaintingStyle paintingStyle,
  }) {
    return TextField(
      focusNode: textNode,
      autofocus: true,
      textInputAction: TextInputAction.newline,
      controller: editorNotifier.textController,
      textAlign: editorNotifier.textAlign,
      style: AppFonts.getTextThemeENUM(
              controlNotifier.fontList![editorNotifier.fontFamilyIndex])
          .bodyLarge!
          .copyWith(
            color: controlNotifier.colorList![editorNotifier.textColor],
            height: 1.4,
            fontSize: editorNotifier.textSize,
            background: Paint()
              ..strokeWidth = 30.0
              ..color = editorNotifier.backGroundColor
              ..style = paintingStyle
              ..strokeJoin = StrokeJoin.round
              ..filterQuality = FilterQuality.high
              ..strokeCap = StrokeCap.round
              ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 1),
          ),
      cursorColor: controlNotifier.colorList![editorNotifier.textColor],
      minLines: 1,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: null,
      onChanged: (value) {
        editorNotifier.text = value;
      },
    );
  }
}
