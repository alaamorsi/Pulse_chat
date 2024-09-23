import 'package:flutter/material.dart';

class AppTheme {
  // Update the lightTheme to accept the selected canvas color
  static ThemeData lightTheme(Color canvasColor) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.grey[300],
      primaryColor: Colors.white,
      secondaryHeaderColor: Colors.black,
      canvasColor: canvasColor,
    );
  }

  // Update the darkTheme to accept the selected canvas color
  static ThemeData darkTheme(Color canvasColor) {
    return ThemeData(
      scaffoldBackgroundColor: Colors.blueGrey.shade900,
      primaryColor: Colors.black,
      secondaryHeaderColor: Colors.white,
      canvasColor: canvasColor,
    );
  }
}
