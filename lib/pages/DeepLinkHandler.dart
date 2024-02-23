import 'package:flutter/material.dart';

class DeepLinkHandler extends StatelessWidget {
  final String userId;
  final String secret;

  const DeepLinkHandler({super.key, required this.userId, required  this.secret});

  @override
  Widget build(BuildContext context) {// Retrieve secret using the userId
    return Text('Go back to the Home screen $userId $secret'); // Replace with your desired content
  }
}