import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/setup_password_screen.dart';
import 'screens/verify_password_screen.dart';

void main() {
  runApp(PicturePassApp());
}

class PicturePassApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Picture Pass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/setup': (context) => SetupPasswordScreen(),
        '/verify': (context) => VerifyPasswordScreen(),
      },
    );
  }
}
