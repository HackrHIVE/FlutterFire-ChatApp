import 'package:firebase_chatapp/Helper/Auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignInButtonBuilder(
              key: ValueKey("Google"),
              text: 'Sign in with Google',
              textColor: Theme.of(context).colorScheme.onSecondary,
              image: Container(
                margin: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image(
                    image: AssetImage(
                      'assets/logos/google_light.png',
                      package: 'flutter_signin_button',
                    ),
                    height: 36.0,
                  ),
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              onPressed: () => authService.googleSignIn(),
              padding: EdgeInsets.all(4.0),
              innerPadding: EdgeInsets.all(0.0),
              height: 36.0,
            ),
          ],
        ),
      ),
    );
  }
}
