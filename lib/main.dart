import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:utask/providers/note_provider.dart';
import 'database/objectbox.dart';
import 'providers/drag_provider.dart';
import 'providers/list_provider.dart';
import 'providers/notebook.dart';
import 'providers/taskProvider.dart';
import 'router/router.dart';
import 'providers/task_provider.dart';

late ObjectBox objectbox;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectbox = await ObjectBox.create();
  final GoRouter router = buildRouter();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<TasksAPI>(create: (context) => TasksAPI()),
      ChangeNotifierProvider<TasksProvider>(create: (context) => TasksProvider()),
      ChangeNotifierProvider<NotesProvider>(create: (context) => NotesProvider()),
      ChangeNotifierProvider<NoteBookProvider>(create: (context) => NoteBookProvider()),
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
