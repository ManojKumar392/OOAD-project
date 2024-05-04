import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase/auth.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _githubController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _passwordController2 = TextEditingController();
  bool passwordValid = false;
  String message = " ";
  String _selectedRole = "Developer";

  @override
  void initState() {
    super.initState();
    _githubController.text = "";
    _nameController.text = "";
    _passwordController.text = "";
    _passwordController2.text = "";
    _emailController.text = "";
  }

  @override
  void dispose() {
    _githubController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _passwordController2.dispose();
    _emailController.dispose();

    super.dispose();
  }

  Widget build(BuildContext context) {
    String password = " ";
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset(
              'assets/auth.png',
              width: 500,
              height: 500,
            ),
            SizedBox(
              width: width * 0.4,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your Name',
                    ),
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your Email',
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                    },
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        setState(() {
                          passwordValid = true;
                        });
                        return 'Password is required please enter';
                      }

                      return null;
                    },
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your password',
                    ),
                  ),
                  TextFormField(
                    controller: _passwordController2,
                    obscureText: true,
                    onChanged: (value) {
                      if (_passwordController.text !=
                          _passwordController2.text) {
                        setState(() {
                          message = "Passwords don't match";
                          print("4");
                        });
                      } else {
                        setState(() {
                          message = "";
                          print("5");
                        });
                      }
                    },
                    validator: (value) {
                      if (value != null && value.isEmpty) {
                        setState(() {
                          passwordValid = true;
                          print("3");
                        });
                        return 'Conform password is required please enter';
                      }
                      if (value != password) {
                        setState(() {
                          passwordValid = true;
                          print("1");
                        });
                        return 'Confirm password not matching';
                      }

                      setState(() {
                        passwordValid = false;
                        print("2");
                      });
                      return null;
                    },
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Re-enter your password',
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  SizedBox(
                    width: width * 0.5,
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.black, fontSize: 17),
                      underline: Container(
                        height: 2,
                        color: Colors.black,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                      items: <String>[
                        'Tech Lead',
                        'Project Manager',
                        'Developer'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  TextFormField(
                    controller: _githubController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Enter your GitHub ID',
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                  ),
                  TextButton(
                    onPressed: () {
                      registerAndAddUser(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                        _selectedRole,
                        _githubController.text,
                        context,
                      );
                    },
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                            Size(width * 0.5, height * 0.08)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                  ),
                  SizedBox(height: height * 0.03),
                  TextButton(
                    onPressed: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      pref.setString(
                          "email", _emailController.text.trim().toString());
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) => SignIn()));
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.white)),
                    child: const Text(
                      "Have an account? Sign In",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                  Text(
                    message,
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }
}
