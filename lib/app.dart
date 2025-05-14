import 'package:flutter/material.dart';
import 'package:sayfbolt/auth/loginscreen.dart';
import 'package:sayfbolt/screens/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sayf Bolt',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(), // Create this screen
      },
    );
  }
}