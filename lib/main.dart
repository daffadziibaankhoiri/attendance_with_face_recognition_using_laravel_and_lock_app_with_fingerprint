import 'package:attendance_with_laravel/splash_screen.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
