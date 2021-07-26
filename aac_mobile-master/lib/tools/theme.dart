import 'package:flutter/material.dart';

final ColorScheme colorScheme1 = ColorScheme.light(
  primary: const Color(0xFF5D1049),
  secondary: const Color(0xFFE30425)
);

final ColorScheme lightScheme = ColorScheme.light();

final ColorScheme darkScheme = ColorScheme.dark();

final ColorScheme highContrastLight = ColorScheme.light(
  primary: const Color(0xff0000ba),
  primaryVariant: const Color(0xff000088),
  secondary: const Color(0xff66fff9),
  secondaryVariant: const Color(0xff018786),
  surface: Colors.white,
  background: Colors.white,
  error: const Color(0xff790000),
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.white,
  brightness: Brightness.light,
);

final ColorScheme highContrastDark = ColorScheme.light(
  primary: const Color(0xffefb7ff),
  primaryVariant: const Color(0xffbe9eff),
  secondary: const Color(0xff66fff9),
  secondaryVariant: const Color(0xff66fff9),
  surface: const Color(0xff121212),
  background: const Color(0xff121212),
  error: const Color(0xff9b374d),
  onPrimary: Colors.black,
  onSecondary: Colors.black,
  onSurface: Colors.white,
  onBackground: Colors.white,
  onError: Colors.black,
  brightness: Brightness.dark,
);



List<Color> colores = [
  Color(0xff043353),  //Marine Blue
  Color(0xff18a4e0),  //Bright Cerulean
  Color(0xffd3dde6)   //Nordic Breeze
];