import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:random_color_scheme/random_color_scheme.dart';

ThemeData getLightThemeFromSeed() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.green,
    ),
  );
}

ThemeData getDarkThemeFromSeed() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.green, brightness: Brightness.dark),
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
  );
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
  );
}

ThemeData getDarkThemeFlexColor() {
  return FlexThemeData.dark(scheme: FlexScheme.dellGenoa, useMaterial3: true);
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

  TextStyle get primaryText => TextStyle(color: theme.primaryColor);
}