import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/auth.dart';

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = context.read<AuthAPI>().username;
    return Scaffold(
      appBar: AppBar(title: const Text('Details Screen')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => {context.read<AuthAPI>().signOut()},
            child: Text('Go back to the Home screen $username'),
        ),
      ),
    );
  }
}

// 