import 'package:flutter/material.dart';
import 'package:poddin_moment_designer/src/presentation/widgets/animated_onTap_button.dart';

class ToolButton extends StatelessWidget {
  final Function() onTap;
  final Widget child;
  final Color? backGroundColor;
  final EdgeInsets? padding;
  final Function()? onLongPress;
  final Color colorBorder;
  final bool? borderHide;
  final Size? size;
  final bool? topPadding;
  const ToolButton({
    super.key,
    required this.onTap,
    required this.child,
    this.backGroundColor,
    this.padding,
    this.onLongPress,
    this.colorBorder = Colors.white,
    this.size = const Size(40, 40),
    this.borderHide = false,
    this.topPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: topPadding! ? const EdgeInsets.only(top: 8) : EdgeInsets.zero,
      child: AnimatedOnTapButton(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(90),
            shadowColor: Colors.black.withOpacity(0.5),
            child: Container(
              height: size?.height ?? 40,
              width: size?.width ?? 40,
              decoration: BoxDecoration(
                  color: backGroundColor ?? Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: borderHide! ? Colors.transparent : Colors.white,
                      width: 1.2)),
              child: Transform.scale(
                scale: 0.8,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
