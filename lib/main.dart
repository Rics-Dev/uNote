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
    // _handleIncomingLinks();
    // final value = context.watch<AuthAPI>().status;
    return MaterialApp.router(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        ),
        routerConfig: widget.router);
  }
}






// final GoRouter _router = GoRouter(
//   routes: [
//     GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//         final value = context.watch<AuthAPI>().status;
//         if (value == AuthStatus.uninitialized) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         } else if (value == AuthStatus.authenticated) {
//           return const DetailsScreen();
//         } else {
//           return const LandingPage(userId: '', secret: '');
//         }
//       },
//     ),
//     GoRoute(
//         path: '/auth/magic-url',
//         builder: (BuildContext context, GoRouterState state) {
//           // Extrait les paramètres userId et secret de l'URL
//           String userId = state.uri.queryParameters['userId'] ?? '';
//           String secret = state.uri.queryParameters['secret'] ?? '';

//           if (userId.isNotEmpty && secret.isNotEmpty ) {
//             return LandingPage(userId: userId, secret: secret);
//           } else {
//             return const LandingPage(userId: '', secret: '');
//           }
//         }),
//   ],
// );