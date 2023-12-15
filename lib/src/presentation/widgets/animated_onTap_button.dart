// ignore_for_file: file_names, library_private_types_in_public_api, unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedOnTapButton extends StatefulWidget {
  final Widget child;
  final void Function() onTap;
  final Function()? onLongPress;

  const AnimatedOnTapButton(
      {super.key, required this.onTap, required this.child, this.onLongPress});

  @override
  _AnimatedOnTapButtonState createState() => _AnimatedOnTapButtonState();
}

class _AnimatedOnTapButtonState extends State<AnimatedOnTapButton>
    with TickerProviderStateMixin {
  double squareScaleA = 1;
  AnimationController? _controllerA;
  Timer _timer = Timer(const Duration(milliseconds: 300), () {});

  @override
  void initState() {
    if (mounted) {
      _controllerA = AnimationController(
        vsync: this,
        lowerBound: 0.9,
        upperBound: 1.0,
        value: 1,
        duration: const Duration(milliseconds: 10),
      );
      _controllerA?.addListener(() {
        setState(() {
          squareScaleA = _controllerA!.value;
        });
      });
      super.initState();
    }
  }

  @override
  void dispose() {
    if (mounted) {
      _controllerA!.dispose();
      _timer.cancel();
      super.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        _controllerA!.reverse();
        widget.onTap();
      },
      onTapDown: (dp) {
        _controllerA!.reverse();
        widget.onLongPress;
      },
      onTapUp: (dp) {
        try {
          if (mounted) {
            _timer = Timer(const Duration(milliseconds: 100), () {
              //  _controllerA!.fling();
            });
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      onTapCancel: () {
      // _controllerA!.fling();
      },
      child: Transform.scale(
        scale: squareScaleA,
        child: widget.child,
      ),
    );
  }
}
