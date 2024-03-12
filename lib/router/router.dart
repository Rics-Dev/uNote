import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../pages/landing_page.dart';
import '../pages/pomodoro_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/build_landing_page.dart';

GoRouter buildRouter([String? userID]) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          final value = context.watch<AuthAPI>().status;
          return buildLandingPage(value, state.uri.queryParameters, userID);
        },
      ),
      GoRoute(
        path: '/pomodoro',
        builder: (BuildContext context, GoRouterState state) {
          return const PomodoroPage();
        },
      ),
      GoRoute(
        path: '/landingPage',
        builder: (BuildContext context, GoRouterState state) {
          return const LandingPage(userId: '', secret: '');
        },
      ),
      GoRoute(
        path: '/auth/magic-url',
        builder: (BuildContext context, GoRouterState state) {
          return buildLandingPage(
            AuthStatus.uninitialized,
            state.uri.queryParameters,
            userID,
          );
        },
      ),
    ],
  );
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