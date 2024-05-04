import 'package:flutter/material.dart';
import 'package:project_management_app/admin/viewFeedback.dart';

import 'addAdmin.dart';
import 'adminListDevelopers.dart';
import 'adminProjectView.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Center(
      child: Container(
        width: width * 0.8,
        decoration: BoxDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
              ),
              child: ListTile(
                title: const Text(
                  "Developer Admin View",
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminDeveloperView()));
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
              ),
              child: ListTile(
                title: Text(
                  "Project Admin View",
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminProjectView()));
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
              ),
              child: ListTile(
                title: Text(
                  "Add Admin",
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddAdmin()));
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
              ),
              child: ListTile(
                title: const Text(
                  "Feedback View",
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ViewFeedback()));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
