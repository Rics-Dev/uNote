import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';
import '../widgets/build_landing_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          final value = context.watch<AuthAPI>().status;
          return buildLandingPage(value, state.uri.queryParameters);
        },
      ),
      GoRoute(
        path: '/auth/magic-url',
        builder: (BuildContext context, GoRouterState state) {
          return buildLandingPage(
            AuthStatus.uninitialized,
            state.uri.queryParameters,
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