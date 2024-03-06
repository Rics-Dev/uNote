import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/landing_page.dart';
import '../providers/auth_provider.dart';

Widget buildLandingPage(AuthStatus authStatus, Map<String, String> queryParameters, [String? userID]) {
  final userId = queryParameters['userId'] ?? '';
  final secret = queryParameters['secret'] ?? '';


  if (userID != null) {
    return const HomePage();
  } 

  if (userId.isNotEmpty && secret.isNotEmpty) {
    return LandingPage(userId: userId, secret: secret);
  }

  switch (authStatus) {
    case AuthStatus.uninitialized:
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    case AuthStatus.authenticated:
      return const HomePage();
    default:
      return const LandingPage(userId: '', secret: '');
  }
}





  // final SharedPreferences prefs = await SharedPreferences.getInstance();
  // final userID = prefs.getString('userID');
  // if (userID != null) {
  //   return HomePage();
  // }
