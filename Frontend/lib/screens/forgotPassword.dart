import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_management_app/widgets/progressIndicator.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  bool isLoading = false;

  Future<void> _resetPassword() async {
    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim())
          .onError((error, stackTrace) => throw error.toString());

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success',
          message: 'Email Sent',
          contentType: ContentType.success,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);

      // Delay the navigation back to the login screen
      await Future.delayed(Duration(seconds: 2));

      Navigator.pop(context); // Pop this screen to go back to the login screen
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Error: $e',
          contentType: ContentType.failure,
        ),
      );

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return isLoading?Scaffold(
      body: Container(
        color: Colors.black.withOpacity(0.5), // Dark semi-transparent background
        child: Center(
          child: CustomProgressIndicator(),
        ),
      ),
    ): Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: width * 0.1),
            child: Center(
              child: Column(
                children: [
                  Text(
                    "Receive a password reset link in your email",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: height * 0.01),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Re-enter your email',
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  TextButton(
                    onPressed: isLoading ? null : _resetPassword, // Disable the button when loading
                    style: ButtonStyle(
                      fixedSize: MaterialStateProperty.all(Size(width * 0.5, height * 0.006)),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                    ),
                    child: const Text(
                      "Reset Password",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
