import 'package:firebase_chatapp/auth.dart';
import 'package:flutter/material.dart';

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
            StreamBuilder(
              stream: authService.user,
              builder: (context, snapshot) {
                return MaterialButton(
                  onPressed: () => authService.googleSignIn(),
                  color: Colors.white,
                  textColor: Colors.black,
                  child: Text('Login with Google'),
                );
              },
            ),
            // LoginData(),
          ],
        ),
      ),
    );
  }
}

class LoginData extends StatefulWidget {
  @override
  _LoginDataState createState() => _LoginDataState();
}

class _LoginDataState extends State<LoginData> {
  Map<String, dynamic> _profile;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    authService.profile.listen(
      (state) {
        setState(
          () {
            _profile = state;
          },
        );
      },
    );
    authService.loading.listen(
      (value) {
        setState(
          () {
            _loading = value;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.0),
          child: Text(_profile != null ? _profile.toString() : "No UserData"),
        ),
        Text(_loading.toString()),
      ],
    );
  }
}
