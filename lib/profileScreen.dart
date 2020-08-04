import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.currentUser().asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            FirebaseUser user = snapshot.data;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(
                      user.photoUrl.toString(),
                    ),
                  ),
                  Text(
                    user.displayName.toString(),
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    user.email.toString(),
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
            );
          } else
            return Center(
              child: Text('Loading Profile...'),
            );
        },
      ),
    );
  }
}
