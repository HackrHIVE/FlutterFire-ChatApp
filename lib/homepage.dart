import 'package:flutter/material.dart';

import 'auth.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic> _profile;
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_profile != null)
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  _profile['photo'].toString(),
                ),
              ),
            if (_profile != null)
              Text(
                _profile['name'].toString(),
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            if (_profile != null)
              Text(
                _profile['email'].toString(),
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            MaterialButton(
              onPressed: () => authService.signOut(),
              child: Text('Signout'),
              textColor: Colors.black,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
