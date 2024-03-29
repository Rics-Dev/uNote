import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/home_page.dart';
import '../pages/note_page.dart';
import '../pages/pomodoro_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const HomePage();
        },
        // routes: <RouteBase>[
        //   GoRoute(
        //     path: 'noteDetails',
        //     builder: (BuildContext context, GoRouterState state) {
        //       final noteId = int.parse(state.uri.queryParameters['noteId']!);
        //       return NoteDetailPage(noteId: noteId);
        //     },
        //   ),
        // ],
      ),
    ],
  );
}
