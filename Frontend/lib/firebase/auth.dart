import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_management_app/repository/user_repository.dart';

import '../screens/home.dart';

Future<void> registerAndAddUser(String email, String password, String name,
    String selectedRole, String github, BuildContext context) async {
  try {
    // Create user with FirebaseAuth
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        )
        .onError((error, stackTrace) => throw FirebaseAuthException(
            code: "404", message: error.toString()));
    if (userCredential.user == null) {
      throw FirebaseAuthException(
          code: "404", message: "User not created. Please try again.");
    }
    String uid = userCredential.user!.uid;
    await UserRepository().createUser(uid, email, name, selectedRole);
    // FCM().updateToken(collection: 'Users', document: uid.toString());
    // Navigate to home screen after successful registration
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Home()));
  } on FirebaseAuthException catch (e) {
    var message = 'An error occurred while creating the account: ${e.message}';
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error',
        message: message,
        contentType: ContentType.failure,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  } catch (e) {
    var message = 'An error occurred: $e';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
