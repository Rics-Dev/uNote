import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool loading = false;

  void signIn() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            backgroundColor: Colors.transparent,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircularProgressIndicator(),
                ]),
          );
        });

    try {
      final AuthAPI appwrite = context.read<AuthAPI>();
      await appwrite.signIn(
        email: emailTextController.text,
        password: passwordTextController.text,
      );
      emailTextController.clear();
      emailTextController.clear();
      // if (context.mounted) Navigator.pop(context);
      if (context.mounted) context.pop();
    } on AppwriteException catch (e) {
      if (context.mounted) Navigator.pop(context);
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  void signInWithProvider(String provider) async {
    try {
      final AuthAPI appwrite = context.read<AuthAPI>();
      await appwrite.signInWithProvider(provider: provider);
      // if (context.mounted) Navigator.pop(context);
      if (context.mounted) context.pop();
    } on AppwriteException catch (e) {
      if (context.mounted) Navigator.pop(context);
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appwrite App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailTextController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordTextController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  signIn();
                },
                icon: const Icon(Icons.login),
                label: const Text("Sign in"),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Create Account'),
              ),
              // TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //             builder: (context) => const MessagesPage()));
              //   },
              //   child: const Text('Read Messages as Guest'),
              // ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => signInWithProvider('google'),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white),
                    child: SvgPicture.asset('assets/google.svg', width: 12),
                  ),
                  ElevatedButton(
                    onPressed: () => signInWithProvider('github'),
                    style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.white),
                    child: SvgPicture.asset('assets/github.svg', width: 12),
                  ),
                  // ElevatedButton(
                  //   onPressed: () => signInWithProvider('apple'),
                  //   style: ElevatedButton.styleFrom(
                  //       foregroundColor: Colors.black,
                  //       backgroundColor: Colors.white),
                  //   child: SvgPicture.asset('assets/apple_icon.svg', width: 12),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () => signInWithProvider('github'),
                  //   style: ElevatedButton.styleFrom(
                  //       foregroundColor: Colors.black,
                  //       backgroundColor: Colors.white),
                  //   child:
                  //       SvgPicture.asset('assets/github_icon.svg', width: 12),
                  // ),
                  // ElevatedButton(
                  //   onPressed: () => signInWithProvider('twitter'),
                  //   style: ElevatedButton.styleFrom(
                  //       foregroundColor: Colors.black,
                  //       backgroundColor: Colors.white),
                  //   child:
                  //       SvgPicture.asset('assets/twitter_icon.svg', width: 12),
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  showAlert({required String title, required String text}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }
}
