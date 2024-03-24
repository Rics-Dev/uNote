import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/drag_provider.dart';
import 'providers/list_provider.dart';
import 'router/router.dart';
import 'providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  String? userID = await secureStorage.read(key: 'userID');
  final GoRouter router = buildRouter(userID);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<TasksAPI>(create: (context) => TasksAPI()),
      ChangeNotifierProvider<ListsAPI>(create: (context) => ListsAPI()),
      ChangeNotifierProvider<DragStateProvider>(
          create: (context) => DragStateProvider()),
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
