import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({super.key});

  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _makeUserAdmin(String email) async { // TODO CHANGE THIS
    try {

      var userQuery = await _firestore
          .collection('Users')
          .where('GitHub', isEqualTo: email) // Assuming 'githubId' is the field name
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        // No user found with this GitHub ID
        throw FirebaseException(
            plugin: 'firebase_firestore',
            code: 'not-found',
            message: 'No user found with GitHub ID: $email');
      }
      else
        {
          var userDoc = userQuery.docs.first;
          await _firestore
              .collection('Users')
              .doc(userDoc.id) // Get the document ID from the query result
              .update({'isAdmin': true}); //

          final snackBar = SnackBar(

            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success',
              message:
              'User $email has been made an admin.',
              contentType: ContentType.success,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }


    } on FirebaseException catch (e) {


      final snackBar = SnackBar(
        
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message:
          'Error updating admin status: ${e.message}',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery. of(context). size. width ;
    double height = MediaQuery. of(context). size. height ;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Admin'),

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'User Github ID',

              ),

            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_emailController.text.isNotEmpty) {
                  _makeUserAdmin(_emailController.text.trim());
                } else {

                  final snackBar = SnackBar(
                    
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Error',
                      message:
                      'Please enter an email',
                      contentType: ContentType.failure,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(snackBar);
                }
              },
                style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(Size(width * 0.7, height*0.006)),
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.black)
                ),
              child: Text('Make User Admin',style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
