import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/drag_provider.dart';
import 'router/router.dart';
import 'providers/auth.dart';
import 'providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final userID = prefs.getString('userID');
  final GoRouter router = buildRouter(userID);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthAPI>(create: (context) => AuthAPI()),
      ChangeNotifierProvider<TasksAPI>(create: (context) => TasksAPI()),
      ChangeNotifierProvider<DragStateProvider>(create: (context) => DragStateProvider()),
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
