// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_import
import 'package:flutter/material.dart';
import 'package:poddin_moment_designer/src/domain/models/editable_items.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';

class WidgetAligner extends StatefulWidget {
  const WidgetAligner({
    super.key,
    this.activeItem,
  });

  final EditableItem? activeItem;

  @override
  State<WidgetAligner> createState() => _WidgetAlignerState();
}

class _WidgetAlignerState extends State<WidgetAligner> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var offset = widget.activeItem != null ? widget.activeItem!.position : null;
    debugPrint('Offset: $offset');

    return Builder(builder: (context) {
      if (widget.activeItem == null) {
        return const SizedBox();
      }
      return Stack(
        alignment: const AlignmentDirectional(0, 0),
        children: [
          // Vertical Alignment
          if (offset!.dx == 0.0 && offset.dy <= 0.3)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
              child: Container(
                width: 1.5,
                height: size.height * 1,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 0, 76),
                ),
              ),
            ),
          // Horizontal Alignment
          if (offset == const Offset(0.0, 0.0))
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 5, 0),
              child: Container(
                width: size.width,
                height: 1.5,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 0, 76),
                ),
              ),
            ),
        ],
      );
    });
  }
}
