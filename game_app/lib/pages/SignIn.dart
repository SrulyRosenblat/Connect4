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
    );
  }
}
