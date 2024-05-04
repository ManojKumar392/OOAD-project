import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_management_app/developer/projectDetailScreen.dart';

import '../widgets/progressIndicator.dart';

class DeveloperHome extends StatefulWidget {
  const DeveloperHome({super.key});

  @override
  State<DeveloperHome> createState() => _DeveloperHomeState();
}

class _DeveloperHomeState extends State<DeveloperHome> {
  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Text("Select a project to report hours")),
        StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data?.data() == null) {
              return Center(
                  child: Text(
                "You have no assigned projects.",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ));
            }

            var userData = snapshot.data!.data() as Map<String, dynamic>;
            List<String> userProjects =
                userData['projectsAlloted']?.cast<String>() ?? [];

            userProjects.sort((a, b) => a.compareTo(b));

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 0,
                  columns: const [
                    DataColumn(
                        label: Expanded(
                            child: Text(
                      'Project Name',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )))
                  ],
                  rows: userProjects.map((projectName) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Text(projectName),
                                Icon(Icons.arrow_right)
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ProjectDetailScreen(
                                  projectTitle: projectName),
                            ));
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
