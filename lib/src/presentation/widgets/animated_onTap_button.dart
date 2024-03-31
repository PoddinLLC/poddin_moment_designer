// ignore_for_file: file_names, library_private_types_in_public_api, unused_import
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedOnTapButton extends StatefulWidget {
  final Widget child;
  final Function() onTap;
  final void Function()? onLongPress;
  final void Function()? onDoubleTap;
  final bool? showLoading;
  final bool? hideChild;

  const AnimatedOnTapButton({
    super.key,
    required this.onTap,
    required this.child,
    this.onLongPress,
    this.showLoading,
    this.onDoubleTap,
    this.hideChild,
  });

  @override
  _AnimatedOnTapButtonState createState() => _AnimatedOnTapButtonState();
}

class _AnimatedOnTapButtonState extends State<AnimatedOnTapButton>
    with TickerProviderStateMixin {
  double squareScaleA = 1;
  bool loading = false;
  bool showChild = true;
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
      onTap: () async {
        if (widget.showLoading ?? false) {
          if (loading) {
            return;
          }
          _controllerA!.reverse();
          setState(() {
            showChild = widget.hideChild != null ? false : true;
            loading = true;
          });
          try {
            await widget.onTap();
          } finally {
            if (mounted) {
              setState(() {
                showChild = true;
                loading = true;
              });
            }
          }
        } else {
          _controllerA!.reverse();
          widget.onTap();
        }
      },
      onTapDown: (dp) {
        _controllerA!.reverse();
      },
      onTapUp: (dp) {
        try {
          if (mounted) {
            _timer = Timer(const Duration(milliseconds: 100), () {
              _controllerA!.fling();
            });
          }
        } catch (e) {
          if (kDebugMode) debugPrint(e.toString());
        }
      },
      onTapCancel: () {
        _controllerA!.fling();
      },
      onLongPress: () => widget.onLongPress?.call(),
      onDoubleTap: () => widget.onDoubleTap?.call(),
      child: Transform.scale(
        scale: squareScaleA,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showChild) widget.child,
            if (loading)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: SizedBox.square(
                  dimension: widget.hideChild != null ? 22 : 18,
                  child: const CircularProgressIndicator(
                    strokeWidth: 1.2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
