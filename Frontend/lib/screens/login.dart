import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_management_app/repository/user_repository.dart';
import 'package:project_management_app/screens/forgotPassword.dart';
import 'package:project_management_app/screens/home.dart';
import 'package:project_management_app/screens/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/FCM.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    TextInput.finishAutofillContext();
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      bool isActive =
          await UserRepository().getActiveStatus(userCredential.user!.uid);
      if (isActive) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        pref.setString("email", _emailController.text.trim());
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const Home()));
        FCM().updateToken(
            collection: 'users', document: userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      showErrorSnackBar('Login failed: ${e.message}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Management App'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/auth.png', width: 500, height: 500),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.4,
                  child: AutofillGroup(
                    child: Column(
                      children: [
                        TextFormField(
                          autofillHints: const [AutofillHints.email],
                          controller: _emailController,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Enter your email',
                          ),
                        ),
                        TextFormField(
                          autofillHints: const [AutofillHints.password],
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Enter your password',
                          ),
                          onFieldSubmitted: (_) {
                            if (!_isLoading) {
                              _login();
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.06),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                        Size(width * 0.4, height * 0.08)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Login",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                ),
                SizedBox(height: height * 0.03),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignUp()));
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
                SizedBox(height: height * 0.03),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPassword()));
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF974061),
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
