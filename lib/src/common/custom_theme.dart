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
  return FlexThemeData.light(scheme: FlexScheme.dellGenoa, useMaterial3: true);
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
