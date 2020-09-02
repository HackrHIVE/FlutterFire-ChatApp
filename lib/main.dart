import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'homepage.dart';
import 'loginpage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ChatApp',
      theme: ThemeData(
        colorScheme: ColorScheme(
          primary: Color(0xff6200EE),
          primaryVariant: Color(0xff3700B3),
          secondary: Color(0xffBB86FC),
          secondaryVariant: Color(0xff966acc),
          surface: Colors.white,
          background: Colors.white,
          error: Colors.black,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onBackground: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Center(
              child: Text('Something went wrong!'),
            );
          }
          if (snapshot.connectionState == ConnectionState.done)
            return handleHomePage();
          return Scaffold(
            body: Center(
              child: Lottie.file(
                'assets/loader.json',
                repeat: true,
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget handleHomePage() {
  return StreamBuilder(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (BuildContext context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting)
        return Scaffold(
          body: Center(
            child: Lottie.file(
              'assets/loader.json',
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
