import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme(BuildContext context) {
  return ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
    colorScheme: const ColorScheme.light(
      primary: Colors.white,
      secondary: Colors.blueGrey,
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.black,
      brightness: Brightness.light,
    ),
  );
}

ThemeData darkTheme(BuildContext context) {
  return ThemeData(
    textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
    colorScheme: ColorScheme.dark(
      background: Colors.grey.shade900,
      // background: Colors.black,
      primaryContainer: Colors.black54,
      primary: Colors.grey.shade900,
      onPrimary: Colors.grey.shade100,
      secondary: Colors.white54,
      onSecondary: Colors.grey.shade400,
      surface: Colors.white38,
      onSurface: Colors.grey.shade100,
      // eaf2f5
      // onSurfaceVariant: const Color(0xffeaf2f5),
      // onSurfaceVariant: Colors.blue[50],
      onSurfaceVariant: Colors.grey.shade200,
      // onTertiaryContainer: const Color(0xff006783),
      error: Colors.red,
      onBackground: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
  );
}
