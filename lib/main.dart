// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
// import 'package:utask/providers/ad_provider.dart';
import 'package:utask/providers/note_provider.dart';
import 'package:utask/theme/theme.dart';
import 'database/objectbox.dart';
import 'providers/notebook.dart';
import 'providers/task_provider.dart';
import 'router/router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

late ObjectBox objectbox;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // final initFuture = MobileAds.instance.initialize();
  // final adState = AdProvider(initFuture);
  // unawaited(MobileAds.instance.initialize());
  objectbox = await ObjectBox.create();
  final GoRouter router = buildRouter();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<TasksProvider>(
          create: (context) => TasksProvider()),
      ChangeNotifierProvider<NotesProvider>(
          create: (context) => NotesProvider()),
      ChangeNotifierProvider<NoteBookProvider>(
          create: (context) => NoteBookProvider()),
      // ChangeNotifierProvider<AdProvider>(create: (context) => adState),
    ],
    child: MyApp(router: router),
  ));
}

class MyApp extends StatefulWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        // title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(
        //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        //   useMaterial3: true,
        //   textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        //   // fontFamily: 'Onest',
        // ),
        // theme: lightTheme(context),
        // darkTheme: darkTheme(context),

        theme: FlexThemeData.light(
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
          // fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        darkTheme: FlexThemeData.dark(
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
          // To use the Playground font, add GoogleFonts package and uncomment
          // fontFamily: GoogleFonts.notoSans().fontFamily,
        ),
        routerConfig: widget.router);
  }
}
