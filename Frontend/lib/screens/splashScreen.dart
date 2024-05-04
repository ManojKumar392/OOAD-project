import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_management_app/screens/login.dart';
import 'package:project_management_app/widgets/progressIndicator.dart';


import 'home.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      _checkPreferencesAndNavigate();
    });
  }

  void _checkPreferencesAndNavigate() async {
    final user = FirebaseAuth.instance.currentUser;
    Widget nextPage = user == null ? const SignIn() : const Home();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CustomProgressIndicator(size: 100),
      ),
    );
  }
}

