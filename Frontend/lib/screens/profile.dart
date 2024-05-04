import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_management_app/repository/user_repository.dart';

import '../widgets/progressIndicator.dart';

/**
 *
 * things to do
 * 1. add a way to add more category + hours
 *
 */
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isAssigningProject = true;

  bool _isAdmin = false;

  TextEditingController _nameController = TextEditingController();
  TextEditingController _githubController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileScreen();
  }

  Future<void> _fetchProfileScreen() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      Map<String, dynamic> profileData =
          await UserRepository().getProfileDetails(user!.uid);
      setState(() {
        _githubController.text = profileData['gitHub'] ?? '';

        _nameController.text = profileData['name'] ?? '';

        _isLoading = false;
      });
    } catch (e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Error updating admin status: ${e}',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  Future<void> _updateProfileScreen() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      Map<String, dynamic> updatedData = {
        'GitHub': _githubController.text,
        'Name': _nameController.text,
      };

      User? user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user?.uid)
          .update(updatedData);

      setState(() {
        _isSubmitting = false;
      });

      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Success',
          message: 'Profile updated successfully:',
          contentType: ContentType.success,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: _isLoading
          ? Center(child: CustomProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: height * 0.03,
                    ),
                    TextFormField(
                      controller: _githubController,
                      decoration: const InputDecoration(
                        labelText: 'GitHub',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the github id';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                          fixedSize: MaterialStateProperty.all(
                              Size(width * 0.5, height * 0.006)),
                          backgroundColor:
                              MaterialStateProperty.all<Color>(Colors.black)),
                      onPressed: _updateProfileScreen,
                      child: const Text(
                        "Update",
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _githubController.dispose();

    super.dispose();
  }
}
