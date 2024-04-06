import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

// ThemeData lightTheme(BuildContext context) {
//   return ThemeData(
//     textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
//     colorScheme: const ColorScheme.light(
//       primary: Colors.white,
//       secondary: Colors.blueGrey,
//       surface: Colors.white,
//       background: Colors.white,
//       error: Colors.red,
//       onPrimary: Colors.black,
//       onSecondary: Colors.black,
//       onSurface: Colors.black,
//       onBackground: Colors.black,
//       onError: Colors.black,
//       brightness: Brightness.light,
//     ),
//   );
// }

// ThemeData darkTheme(BuildContext context) {
//   return ThemeData(
//     textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
//     colorScheme: ColorScheme.dark(
//       background: Colors.grey.shade900,
//       // background: Colors.black,
//       primaryContainer: Colors.black54,
//       primary: Colors.grey.shade900,
//       onPrimary: Colors.grey.shade100,
//       secondary: Colors.white54,
//       onSecondary: Colors.grey.shade400,
//       surface: Colors.white38,
//       onSurface: Colors.grey.shade100,
//       // eaf2f5
//       // onSurfaceVariant: const Color(0xffeaf2f5),
//       // onSurfaceVariant: Colors.blue[50],
//       onSurfaceVariant: Colors.grey.shade200,
//       // onTertiaryContainer: const Color(0xff006783),
//       error: Colors.red,
//       onBackground: Colors.white,
//       onError: Colors.white,
//       brightness: Brightness.dark,
//     ),
//   );
// }
class ThemeProvider extends ChangeNotifier {
  late ThemeData _themeData;
  ThemeData get themeData => _themeData;

  ThemeProvider() {
    _init();
  }

  void _init() {
    var brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;
    _themeData = isDarkMode ? darkMode : lightMode;
  }

  void toggleTheme() async {
    _themeData = _themeData == lightMode ? darkMode : lightMode;
    notifyListeners();
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool('isDark', _themeData == darkMode);
  }
}

ThemeData lightMode = FlexThemeData.light(
  scheme: FlexScheme.blueWhale,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 7,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 10,
    blendOnColors: false,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    inputDecoratorIsFilled: false,
    inputDecoratorBorderType: FlexInputBorderType.underline,
    inputDecoratorUnfocusedBorderIsColored: false,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
  // To use the Playground font, add GoogleFonts package and uncomment
  fontFamily: GoogleFonts.poppins().fontFamily,
);

ThemeData darkMode = FlexThemeData.dark(
  // colors: const FlexSchemeColor(
  //   primary: Color(0xffc4d7f8),
  //   primaryContainer: Color(0xff577cbf),
  //   secondary: Color(0xfff1bbbb),
  //   secondaryContainer: Color(0xffcb6060),
  //   tertiary: Color(0xffdde5f5),
  //   tertiaryContainer: Color(0xff7297d9),
  //   appBarColor: Color(0xffdde5f5),
  //   error: null,
  // ),
  scheme: FlexScheme.greyLaw,
  surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
  blendLevel: 13,
  subThemesData: const FlexSubThemesData(
    blendOnLevel: 20,
    useTextTheme: true,
    useM2StyleDividerInM3: true,
    // inputDecoratorRadius: 50,
    inputDecoratorIsFilled: false,
    inputDecoratorBorderType: FlexInputBorderType.underline,
    inputDecoratorUnfocusedBorderIsColored: false,
    alignedDropdown: true,
    useInputDecoratorThemeInDialogs: true,
  ),
  visualDensity: FlexColorScheme.comfortablePlatformDensity,
  useMaterial3: true,
  swapLegacyOnMaterial3: true,
  fontFamily: GoogleFonts.poppins().fontFamily,

  // To use the Playground font, add GoogleFonts package and uncomment
  // fontFamily: GoogleFonts.notoSans().fontFamily,
);
