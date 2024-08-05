
import 'package:flutter/material.dart';

class ThemeColors {
  // #0c4524
  static MaterialColor primaryColor = getMaterialColor("#0c4524");
  static MaterialColor accentColor = getMaterialColor("#e5b0a4");
  static MaterialColor backgroundColor = getMaterialColor("#072b1d");

  static MaterialColor getMaterialColor(String hexColor) {
    Color color = Color(int.parse(hexColor.substring(1, 7), radix: 16) + 0xFF000000);
    final int red = color.red;
    final int green = color.green;
    final int blue = color.blue;

    final Map<int, Color> shades = {
      50: Color.fromRGBO(red, green, blue, .1),
      100: Color.fromRGBO(red, green, blue, .2),
      200: Color.fromRGBO(red, green, blue, .3),
      300: Color.fromRGBO(red, green, blue, .4),
      400: Color.fromRGBO(red, green, blue, .5),
      500: Color.fromRGBO(red, green, blue, .6),
      600: Color.fromRGBO(red, green, blue, .7),
      700: Color.fromRGBO(red, green, blue, .8),
      800: Color.fromRGBO(red, green, blue, .9),
      900: Color.fromRGBO(red, green, blue, 1),
    };

    return MaterialColor(color.value, shades);
  }
}
