import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth.dart';
import 'package:sign_button/sign_button.dart';

class LandingPage extends StatefulWidget {
  final String userId;
  final String secret;

  const LandingPage({super.key, required this.userId, required this.secret});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final emailTextController = TextEditingController();
  bool showButtons = false;
  bool showEmailField = false;

  @override
  void initState() {
    super.initState();
    // Access userId and secret from widget properties
    if (widget.userId != '' && widget.secret != '') {
      _verifyMagicURLSession(widget.userId, widget.secret);
    }
  }

  @override
  void dispose() {
    super.dispose();
    // Dispose of the TextEditingController to avoid memory leaks
    emailTextController.dispose();
  }

  void toggleButtons() {
    setState(() {
      showButtons = !showButtons;
    });
  }

  void toggleEmailField() {
    setState(() {
      showEmailField = !showEmailField;
    });
  }

  //not so well
  void signInWithEmail() async {
    try {
      final AuthAPI appwrite = context.read<AuthAPI>();
      await appwrite.signInWithEmail(
        email: emailTextController.text,
      );
      emailTextController.clear();
      //on peut rediriger vers une autre page ici
    } on AppwriteException catch (e) {
      setState(() {});
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  void _verifyMagicURLSession(userId, secret) async {
    try {
      final AuthAPI appwrite = context.read<AuthAPI>();
      await appwrite.verifyMagicURLSession(userId: userId, secret: secret);
      if (context.mounted) context.go('/');
    } on AppwriteException catch (e) {
      setState(() {});
      // if (context.mounted) Navigator.pop(context);
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  //Works well
  void signInWithProvider(String provider) async {
    try {
      final AuthAPI appwrite = context.read<AuthAPI>();
      await appwrite.signInWithProvider(provider: provider);
      setState(() {});
    } on AppwriteException catch (e) {
      setState(() {});
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        );

    final headlineStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w900,
          fontSize: 60,
          // letterSpacing: 4,
        );
    // const spacing = 10.0;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Text(
                      "Welcome",
                      style: headlineStyle,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Center(
                    child: Text(
                      "to uTask",
                      style: headlineStyle,
                    ),
                  ),
                  const SizedBox(height: 140),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: textStyle,
                      children: const [
                        TextSpan(text: 'Your new task management home '),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!showButtons) ...[
                    ElevatedButton(
                      onPressed: toggleButtons,
                      child: const Text('Get Started'),
                    ),
                  ] else ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SignInButton(
                          buttonType: ButtonType.google,
                          buttonSize: ButtonSize.small,
                          customImage: CustomImage("assets/google.png"),
                          // customImage: CustomImage("assets/google.svg"),
                          btnText: 'Google',
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(20.0),
                          // ),
                          // btnTextColor: Colors.grey,

                          width: 130,
                          onPressed: () {
                            signInWithProvider('google');
                          },
                        ),
                        const SizedBox(width: 10),
                        SignInButton(
                          buttonType: ButtonType.microsoft,
                          customImage: CustomImage("assets/microsoft.png"),
                          buttonSize: ButtonSize.small,
                          // customImage: CustomImage("assets/google.svg"),
                          btnText: 'Microsoft',
                          // shape: RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(20.0),
                          // ),
                          // btnTextColor: Colors.grey,

                          width: 130,
                          onPressed: () {
                            signInWithProvider('microsoft');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (!showEmailField) ...[
                      SignInButton(
                        buttonType: ButtonType.mail,
                        customImage: CustomImage("assets/Message - 3.png"),
                        btnText: 'Continue with Email',
                        buttonSize: ButtonSize.small,
                        btnTextColor: Colors.white,
                        btnColor: const Color.fromARGB(255, 52, 52, 52),
                        width: 300,
                        // shape: RoundedRectangleBorder(
                        //   borderRadius: BorderRadius.circular(20.0),
                        // ),
                        // btnTextColor: Colors.grey,

                        onPressed: () {
                          toggleEmailField();
                        },
                      ),
                    ] else ...[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 5),
                        child: TextField(
                          controller: emailTextController,
                          decoration: InputDecoration(
                            labelText: 'Type your Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 2.0,
                            ),
                            fillColor: Colors.grey[200],
                            filled: true,
                            suffixIcon: IconButton(
                              color: Colors.black,
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                signInWithEmail();
                              },
                            ),
                          ),
                          style: const TextStyle(fontSize: 14.0),
                          onSubmitted: (text) {
                            signInWithEmail();
                          },
                        ),
                      ),
                    ],
                  ],
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