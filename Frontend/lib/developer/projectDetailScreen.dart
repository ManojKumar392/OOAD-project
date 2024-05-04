import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../repository/developer_repository.dart';
import '../widgets/progressIndicator.dart';
import '../widgets/timePicker.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectTitle;

  const ProjectDetailScreen({Key? key, required this.projectTitle})
      : super(key: key);

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final TextEditingController _hoursWorkedController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  Map<String, dynamic>? projectData;
  Duration selectedDuration = Duration(hours: 0);
  String? selectedWorkCategory;
  String message = "";
  bool isLoading = true;
  String message2 = "";

  @override
  void initState() {
    super.initState();
    fetchProjectData();
  }

  Future<void> fetchProjectData() async {
    setState(() => isLoading = true);
    bool isActive = true;
    try {
      DocumentSnapshot projectSnapshot = await FirebaseFirestore.instance
          .collection('Clients')
          .doc(widget.projectTitle)
          .get();
      if (projectSnapshot['active'] == false) {
        isActive = false;
      }
      if (projectSnapshot.exists) {
        projectData = projectSnapshot.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      print(e);
    }
    setState(() => isLoading = false);
  }

  void updateHoursAndCreateWorkDocument() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null &&
        selectedWorkCategory != null &&
        _descriptionController.text.isNotEmpty) {
      double enteredHours = selectedDuration.inHours.toDouble() +
          (selectedDuration.inMinutes % 60) / 60.0 +
          (selectedDuration.inSeconds % 60) / 3600.0;

      if (enteredHours <= 0) {
        setState(() {
          message = "Entered hours must be greater than zero.";
          isLoading = false;
        });
        return;
      }
      if (enteredHours > 8) {
        final timeExceeded = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: "Please enter less than 8 hours at a time ",
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(timeExceeded);
        return;
      }

      try {
        setState(() => isLoading = true);

        Map<String, dynamic> workCategories =
            Map<String, dynamic>.from(projectData!['work']);
        double currentHours = (workCategories[selectedWorkCategory] is int)
            ? (workCategories[selectedWorkCategory] as int).toDouble()
            : (workCategories[selectedWorkCategory] as double? ?? 0.0);

        if (enteredHours <= currentHours) {
          double updatedHours = currentHours - enteredHours;
          workCategories[selectedWorkCategory!] = updatedHours;
          Map<String, dynamic> reportWorkData = {
            'Client': widget.projectTitle,
            'Date': Timestamp.now().toDate().toIso8601String(),
            'Description': _descriptionController.text,
            'Hours': enteredHours,
            'Work': selectedWorkCategory,
            'userUID': user.uid,
            'workCategories': workCategories,
            'enteredHours': enteredHours,
          };
          await DeveloperRepository().reportWork(reportWorkData);

          _hoursWorkedController.clear();
          _descriptionController.clear();

          setState(() {
            message2 = "Hours updated and work entry created successfully.";
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success',
                message: "Hours updated and work entry created successfully.",
                contentType: ContentType.success,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
            projectData!['work'] = workCategories;
          });
        } else {
          setState(() {
            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Error',
                message:
                    "Entered hours exceed available hours for this category.",
                contentType: ContentType.failure,
              ),
            );
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          });
        }
      } catch (e) {
        print('An error occurred while updating hours: $e');
        setState(() {
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error',
              message:
                  "An error occurred $e. If this persists, please contact support! Your work is not being recorded",
              contentType: ContentType.failure,
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        });
      } finally {
        setState(() => isLoading = false);
      }
    } else {
      setState(() {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: "Please fill in all fields ",
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.projectTitle)),
        body: Center(child: CustomProgressIndicator()),
      );
    }

    if (projectData == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Project Detail')),
        body: Center(child: Text('No project data available')),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Report Hours"),
            Text('Project Title: ${widget.projectTitle}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Container(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedWorkCategory,
                hint: Text('Select Work Category'),
                items: projectData!['work']
                    .keys
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                        '$value (${projectData!['work'][value]} hours left)'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    selectedWorkCategory = newValue;
                  });
                },
              ),
            ),
            TimePicker(
              initialTimer: selectedDuration,
              onTimeChanged: (Duration newDuration) {
                int totalMinutes = newDuration.inMinutes % 60;
                int adjustedMinutes = totalMinutes - (totalMinutes % 15);
                if (newDuration > Duration(hours: 8)) {
                  final timeExceeded = SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Error',
                      message: "Please enter less than 8 hours at a time ",
                      contentType: ContentType.failure,
                    ),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(timeExceeded);
                }
                setState(() {
                  selectedDuration = Duration(
                      hours: newDuration.inHours, minutes: adjustedMinutes);
                });
              },
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              keyboardType: TextInputType.text,
              maxLines: null,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all(
                        Size(width * 0.7, height * 0.009)),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.black)),
                onPressed: updateHoursAndCreateWorkDocument,
                child: Text(
                  'Update Hours',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Text(
                message,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
