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
