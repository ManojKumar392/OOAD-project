import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController _feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _feedbackController.text = "";
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  void submitFeedback() async {
    DateTime now = DateTime.now();
    String feedbackText = _feedbackController.text.trim();

    if (feedbackText.isNotEmpty) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        await FirebaseFirestore.instance.collection('Feedback').add({
          'feedback': feedbackText,
          'date': now,
          'email': user?.email,
        });

        // Map<String, dynamic> feedbackData = {
        //   'feedback': feedbackText,
        //   'date': now.toIso8601String(),
        //   'email': user?.email,
        // };
        // await FeedbackRepository().addFeedback(feedbackData);
        showSnackbar(
            'Success', 'Feedback submitted successfully.', ContentType.success);
      } catch (e) {
        showSnackbar('Error', 'Error: $e', ContentType.failure);
      }
    } else {
      showSnackbar('Error', 'Please enter feedback before submitting.',
          ContentType.failure);
    }

    _feedbackController.clear(); // Clear the text field
  }

  void showSnackbar(String title, String message, ContentType contentType) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            Text(
              "Don't worry! Your feedback is anonymous :)",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            TextFormField(
              controller: _feedbackController,
              keyboardType: TextInputType.text,
              maxLines: null,
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter your feedback',
              ),
            ),
            SizedBox(height: height * 0.02),
            ElevatedButton(
              onPressed: submitFeedback,
              style: ButtonStyle(
                fixedSize:
                    MaterialStateProperty.all(Size(width * 0.7, height * 0.04)),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              ),
              child: Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
