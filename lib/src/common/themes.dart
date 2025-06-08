import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

abstract final class CustomColors {
  static const Color rainee = Color(0xffb2c79e);
  static const Color frost = Color(0xffe6f5da);
  static const Color pakistanGreen = Color(0xff143312);
  static const Color darkGreen = Color(0xff0C1E0B);
  static const Color orangeFrame = Colors.orange;
  static const Color darkPurple = Color(0xff370926);
  static const Color ashGrey = Color(0xffAEB7B3);
}

@immutable
class ContainersColors extends ThemeExtension<ContainersColors> {
  final Color mainContainerBackground;
  final Color secondaryContainerBackground;
  final Color secondaryContainerFrame;

  const ContainersColors({
    required this.mainContainerBackground,
    required this.secondaryContainerBackground,
    required this.secondaryContainerFrame,
  });

  @override
  ContainersColors copyWith({
    Color? mainContainerBackground,
    Color? secondaryContainerBackground,
    Color? secondaryContainerFrame,
  }) {
    return ContainersColors(
      mainContainerBackground:
          mainContainerBackground ?? this.mainContainerBackground,
      secondaryContainerBackground:
          secondaryContainerBackground ?? this.secondaryContainerBackground,
      secondaryContainerFrame:
          secondaryContainerFrame ?? this.secondaryContainerFrame,
    );
  }

  @override
  ContainersColors lerp(ThemeExtension<ContainersColors>? other, double t) {
    if (other is! ContainersColors) {
      return this;
    }
    return ContainersColors(
      mainContainerBackground: Color.lerp(
        mainContainerBackground,
        other.mainContainerBackground,
        t,
      )!,
      secondaryContainerBackground: Color.lerp(
        secondaryContainerBackground,
        other.secondaryContainerBackground,
        t,
      )!,
      secondaryContainerFrame: Color.lerp(
        secondaryContainerFrame,
        other.secondaryContainerFrame,
        t,
      )!,
    );
  }
}

ThemeData getLightThemeFlexColor() {
  return FlexThemeData.light(
    scheme: FlexScheme.dellGenoa,
    // scaffoldBackground: Color(0xffF5F5DC),
    useMaterial3: true,
    extensions: [
      const ContainersColors(
        mainContainerBackground: CustomColors.rainee,
        secondaryContainerBackground: CustomColors.frost,
        secondaryContainerFrame: CustomColors.orangeFrame,
      ),
    ],
  );
}

ThemeData getDarkThemeFlexColor() {
  return FlexThemeData.dark(
    scheme: FlexScheme.dellGenoa,
    useMaterial3: true,
    extensions: [
      const ContainersColors(
        mainContainerBackground: CustomColors.darkGreen,
        secondaryContainerBackground: CustomColors.pakistanGreen,
        secondaryContainerFrame: CustomColors.ashGrey,
      ),
    ],
  );
}

extension ColorsGenerator on BuildContext {
  List<Color> chartColors(int count) {
    final colorScheme = Theme.of(
      this,
    ).colorScheme; // Use current theme's colorScheme

    // Create an initial list of colors from the colorScheme
    List<Color> baseColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];

    // If you need more colors than available in baseColors, generate variations
    if (count > baseColors.length) {
      final List<Color> additionalColors = [];
      for (int i = 0; i < count - baseColors.length; i++) {
        Color nextColor = baseColors[i % baseColors.length];

        // Vary the hue by a fixed amount
        final hslColor = HSLColor.fromColor(nextColor);
        double hue = hslColor.hue + (i * 40); // Adjust the 40 for hue variation
        if (hue > 360) hue -= 360;

        final newColor = hslColor.withHue(hue).toColor();
        additionalColors.add(newColor);
      }
      baseColors.addAll(additionalColors);
    }

    return baseColors.take(count).toList();
  }

  ThemeData get theme => Theme.of(this);

  TextTheme get textTheme => TextTheme.of(this);

  TextStyle get primaryText => TextStyle(color: theme.primaryColor);
}
