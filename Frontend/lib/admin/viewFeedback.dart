import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../widgets/progressIndicator.dart';

class ViewFeedback extends StatefulWidget {
  const ViewFeedback({Key? key}) : super(key: key);

  @override
  State<ViewFeedback> createState() => _ViewFeedbackState();
}

class _ViewFeedbackState extends State<ViewFeedback> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;
    double height = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback List'),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: width*0.1),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Feedback')
              .orderBy('date', descending: true) // Assuming 'date' is your timestamp field
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No feedback submitted yet.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var feedbackData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                // Create a tile for each feedback entry
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
                  ),
                  child: ListTile(
                    title: Text(feedbackData['feedback'] ?? 'No feedback text provided',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17),),
                    subtitle: Text(feedbackData['date'].toDate().toString()), // Formatting the date as needed
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
