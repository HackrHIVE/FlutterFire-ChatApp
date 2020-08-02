import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'homepage.dart';
import 'loginpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: handleHomePage(),
    );
  }
}

Widget handleHomePage() {
  return StreamBuilder(
    stream: FirebaseAuth.instance.onAuthStateChanged,
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return Scaffold(
          body: Center(
            child: Lottie.network(
              'https://assets2.lottiefiles.com/temp/lf20_XfK5FJ.json',
              repeat: true,
            ),
          ),
        );
      else if (snapshot.hasData)
        return MyHomePage();
      else
        return LoginPage();
    },
  );
}
