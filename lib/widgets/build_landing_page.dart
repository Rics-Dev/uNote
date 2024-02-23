import 'package:flutter/material.dart';
import '../pages/inbox_page.dart';
import '../pages/landing_page.dart';
import '../services/auth.dart';

Widget buildLandingPage(AuthStatus authStatus, Map<String, String> queryParameters) {
  final userId = queryParameters['userId'] ?? '';
  final secret = queryParameters['secret'] ?? '';

  if (userId.isNotEmpty && secret.isNotEmpty) {
    return LandingPage(userId: userId, secret: secret);
  }

  switch (authStatus) {
    case AuthStatus.uninitialized:
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    case AuthStatus.authenticated:
      return const Inbox();
    default:
      return const LandingPage(userId: '', secret: '');
  }
}