import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'router/router.dart';
import 'services/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final GoRouter router = buildRouter();
  runApp(ChangeNotifierProvider(
    create: (context) => AuthAPI(),
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
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
          // textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          fontFamily: 'Onest',
        ),
        routerConfig: widget.router);
  }
}
