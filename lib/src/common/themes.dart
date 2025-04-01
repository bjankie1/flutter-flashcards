import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:random_color_scheme/random_color_scheme.dart';

abstract final class CustomColors {
  static const Color rainee = Color(0xffb2c79e);
  static const Color frost = Color(0xffe6f5da);
  static const Color orangeFrame = Colors.orange;
}

@immutable
class ContainersColors extends ThemeExtension<ContainersColors> {
  final Color mainContainerBackground;
  final Color secondaryContainerBackground;
  final Color secondaryContainerFrame;

  const ContainersColors(
      {required this.mainContainerBackground,
      required this.secondaryContainerBackground,
      required this.secondaryContainerFrame});

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
          mainContainerBackground, other.mainContainerBackground, t)!,
      secondaryContainerBackground: Color.lerp(
          secondaryContainerBackground, other.secondaryContainerBackground, t)!,
      secondaryContainerFrame: Color.lerp(
          secondaryContainerFrame, other.secondaryContainerFrame, t)!,
    );
  }
}

ThemeData getLightThemeFromSeed() {
  return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green,
      ),
      extensions: [
        const ContainersColors(
            mainContainerBackground: CustomColors.rainee,
            secondaryContainerBackground: CustomColors.frost,
            secondaryContainerFrame: CustomColors.orangeFrame)
      ]);
}

ThemeData getDarkThemeFromSeed() {
  return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green, brightness: Brightness.dark),
      extensions: [
        const ContainersColors(
            mainContainerBackground: Colors.deepPurple,
            secondaryContainerBackground: Color(0x00b8860b),
            secondaryContainerFrame: CustomColors.orangeFrame)
      ]
      // brightness: Brightness.dark
      );
}

ThemeData getLightThemeFlexSeed() {
  return ThemeData(
      useMaterial3: true,
      colorScheme: SeedColorScheme.fromSeeds(
        primaryKey: Colors.green,
        secondaryKey: Colors.amber.shade900,
        tertiaryKey: Colors.grey.shade600,
      ),
      extensions: [
        const ContainersColors(
            mainContainerBackground: CustomColors.rainee,
            secondaryContainerBackground: CustomColors.frost,
            secondaryContainerFrame: CustomColors.orangeFrame)
      ]);
}

ThemeData getDarkThemeFlexSeed() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: SeedColorScheme.fromSeeds(
        primaryKey: Colors.green,
        secondaryKey: Colors.amber.shade900,
        tertiaryKey: Colors.grey.shade600,
        brightness: Brightness.dark),
  );
}

ThemeData getLightThemeFlexColor() {
  return FlexThemeData.light(
      scheme: FlexScheme.dellGenoa,
      useMaterial3: true,
      extensions: [
        const ContainersColors(
            mainContainerBackground: CustomColors.rainee,
            secondaryContainerBackground: CustomColors.frost,
            secondaryContainerFrame: CustomColors.orangeFrame)
      ]);
}

ThemeData getDarkThemeFlexColor() {
  return FlexThemeData.dark(
      scheme: FlexScheme.dellGenoa,
      useMaterial3: true,
      extensions: [
        const ContainersColors(
            mainContainerBackground: CustomColors.rainee,
            secondaryContainerBackground: CustomColors.frost,
            secondaryContainerFrame: CustomColors.orangeFrame)
      ]);
}

ThemeData getLightThemeRandom() {
  return ThemeData(
    colorScheme: randomColorSchemeLight(),
  );
}

ThemeData getDarkThemeRandom() {
  return ThemeData(
    colorScheme: randomColorSchemeDark(),
  );
}

extension ColorsGenerator on BuildContext {
  List<Color> chartColors(int count) {
    final colorScheme =
        Theme.of(this).colorScheme; // Use current theme's colorScheme

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