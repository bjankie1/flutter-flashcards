import 'package:flutter/material.dart';
import 'package:flutter_flashcards/src/common/themes.dart';

class CardsContainer extends StatelessWidget {
  final Widget child;

  final bool secondary;

  final EdgeInsets? padding;

  final EdgeInsets? margin;

  const CardsContainer(
      {super.key,
      required this.child,
      this.secondary = false,
      this.padding,
      this.margin});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.extension<ContainersColors>();
    final color = secondary
        ? colors?.secondaryContainerBackground
        : colors?.mainContainerBackground;
    final frameColor = secondary ? colors?.secondaryContainerFrame : null;
    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: color,
          border:
              Border.all(color: frameColor ?? Colors.transparent, width: 2.0)),
      padding: padding,
      margin: margin,
      child: child,
    );
  }
}