import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      sideBuilder: (context, constraints) {
        return const Image(image: const AssetImage("assets/connect4v2.png"));
      },
      providerConfigs: [
        EmailProviderConfiguration(),
        GoogleProviderConfiguration(
          clientId:
              '165156080497-t4lqeabpg69q6ld1tl6l92jk0v3e88mg.apps.googleusercontent.com',
        ),
      ],
      footerBuilder: (context, acion) {
        return FilledButton(
          onPressed: () {
            FirebaseAuth.instance.signInAnonymously();
          },
          child: const Text("Sign In Anonymously"),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.grey),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        );
      },
    );
  }
}
