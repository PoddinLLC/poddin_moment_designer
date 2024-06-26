// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/control_provider.dart';
import 'package:poddin_moment_designer/src/domain/providers/notifiers/painting_notifier.dart';
import 'package:poddin_moment_designer/src/presentation/utils/constants/painting_type.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/tool_button.dart';

class TopPaintingTools extends StatefulWidget {
  const TopPaintingTools({super.key});

  @override
  _TopPaintingToolsState createState() => _TopPaintingToolsState();
}

class _TopPaintingToolsState extends State<TopPaintingTools> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<ControlNotifier, PaintingNotifier>(
      builder: (context, controlNotifier, paintingNotifier, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// remove last line
                if (paintingNotifier.lines.isNotEmpty)
                  ToolButton(
                    onTap: paintingNotifier.removeLast,
                    onLongPress: paintingNotifier.clearAll,
                    backGroundColor: Colors.black12,
                    child: Transform.scale(
                        scale: 0.6,
                        child: const ImageIcon(
                          AssetImage('assets/icons/return.png',
                              package: 'poddin_moment_designer'),
                          color: Colors.white,
                        )),
                  ),

                /// select pen tools
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // pen
                        ToolButton(
                          onTap: () {
                            paintingNotifier.paintingType = PaintingType.pen;
                          },
                          colorBorder:
                              paintingNotifier.paintingType == PaintingType.pen
                                  ? Colors.black
                                  : Colors.white,
                          backGroundColor:
                              paintingNotifier.paintingType == PaintingType.pen
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black12,
                          child: Transform.scale(
                              scale: 1.2,
                              child: ImageIcon(
                                const AssetImage('assets/icons/pen.png',
                                    package: 'poddin_moment_designer'),
                                color: paintingNotifier.paintingType ==
                                        PaintingType.pen
                                    ? Colors.black
                                    : Colors.white,
                              )),
                        ),
                        // marker
                        ToolButton(
                          onTap: () {
                            paintingNotifier.paintingType = PaintingType.marker;
                          },
                          colorBorder: paintingNotifier.paintingType ==
                                  PaintingType.marker
                              ? Colors.black
                              : Colors.white,
                          backGroundColor: paintingNotifier.paintingType ==
                                  PaintingType.marker
                              ? Colors.white.withOpacity(0.9)
                              : Colors.black12,
                          child: Transform.scale(
                              scale: 1.2,
                              child: ImageIcon(
                                const AssetImage('assets/icons/marker.png',
                                    package: 'poddin_moment_designer'),
                                color: paintingNotifier.paintingType ==
                                        PaintingType.marker
                                    ? Colors.black
                                    : Colors.white,
                              )),
                        ),

                        /// neon
                        ToolButton(
                          onTap: () {
                            paintingNotifier.paintingType = PaintingType.neon;
                          },
                          colorBorder:
                              paintingNotifier.paintingType == PaintingType.neon
                                  ? Colors.black
                                  : Colors.white,
                          backGroundColor:
                              paintingNotifier.paintingType == PaintingType.neon
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.black12,
                          child: Transform.scale(
                              scale: 1.2,
                              child: ImageIcon(
                                const AssetImage('assets/icons/neon.png',
                                    package: 'poddin_moment_designer'),
                                color: paintingNotifier.paintingType ==
                                        PaintingType.neon
                                    ? Colors.black
                                    : Colors.white,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    controlNotifier.isPainting = !controlNotifier.isPainting;
                    paintingNotifier.resetDefaults();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10, left: 5),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          border: Border.all(color: Colors.white, width: 1.2),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
