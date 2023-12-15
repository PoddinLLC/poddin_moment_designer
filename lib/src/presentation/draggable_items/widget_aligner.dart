// ignore_for_file: no_leading_underscores_for_local_identifiers, unused_import
import 'package:flutter/material.dart';
import 'package:poddin_moment_designer/src/domain/models/editable_items.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/item_type.dart';

class WidgetAligner extends StatelessWidget {
  const WidgetAligner({
    super.key,
    required EditableItem? activeItem,
  }) : _activeItem = activeItem;

  final EditableItem? _activeItem;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    var offset = _activeItem?.position;
    debugPrint('Offset: $offset');

    return Visibility(
      visible: _activeItem != null,
      child: Stack(
        alignment: const AlignmentDirectional(0, 0),
        children: [
          // Vertical Alignment
          if (offset!.dx == size.width / 2 && offset.dy <= size.height)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 15),
              child: Container(
                width: 1.5,
                height: size.height * 1,
                decoration: const BoxDecoration(
                  color: Color(0xFFD91C54),
                ),
              ),
            ),
          // Horizontal Alignment
          if ((offset.dx == size.width / 2 && offset.dy == size.height / 2) ||
              (offset.dx <= size.width / 2 && offset.dy == size.height / 2))
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
              child: Container(
                width: size.width,
                height: 1.5,
                decoration: const BoxDecoration(
                  color: Color(0xFFD91C54),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
