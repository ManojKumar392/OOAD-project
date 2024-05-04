import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_management_app/repository/project_repository.dart';
import 'package:switcher_button/switcher_button.dart';

class AssignProject extends StatefulWidget {
  final String developerId;

  const AssignProject({Key? key, required this.developerId}) : super(key: key);

  @override
  State<AssignProject> createState() => _AssignProjectState();
}

class _AssignProjectState extends State<AssignProject> {
  String? selectedProjectId;
  bool isAssigningProject = true;
  List<DropdownMenuItem<String>> menuItems = [];
  var projectsList = [];
  var name = "";
  @override
  void initState() {
    super.initState();
    fetchProjects();
  }

  void fetchProjects() async {
    List snapshot = await ProjectRepository().getAllProjects();
    var projects = snapshot
        .map((item) => DropdownMenuItem<String>(
              value: item['name'],
              child: Text(item['name']),
            ))
        .toList();
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.developerId)
          .get();
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      projectsList = userData['projectsAlloted'] ?? [];
      name = userData['name'];
      setState(() {
        menuItems = projects;
        name = userData['name'];
      });
    }
  }

  void assignProject() {
    if (selectedProjectId != null &&
        !projectsList.contains(selectedProjectId)) {
      ProjectRepository()
          .assignDeveloper(selectedProjectId!, widget.developerId)
          .then((_) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Assigned developer to new project successfully!',
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }).catchError((error) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: error.toString(),
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      });
    } else if (projectsList.contains(selectedProjectId)) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Developer already in project',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  void toggleAction() {
    if (selectedProjectId == null) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Select valid project',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
    if (isAssigningProject) {
      assignProject();
    } else {
      removeProject();
    }
  }

  void removeProject() {
    if (selectedProjectId != null && projectsList.contains(selectedProjectId)) {
      FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.developerId)
          .update({
        'ClientsAlloted': FieldValue.arrayRemove([selectedProjectId])
      }).then((_) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Project removed from developer successfully!',
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }).catchError((error) {
        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: '$error',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      });
    } else if (!projectsList.contains(selectedProjectId)) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Developer is not assigned to this project.',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  bool active = true;
  void toggleDeveloperStatus(bool isActive) async {
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.developerId)
        .update({
      'isActive':
          isActive, // This field should be part of your User document schema
    }).then((_) {
      print("Developer status updated.");
    }).catchError((error) {
      print("Failed to update developer status: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: width * 0.1),
        child: Column(
          children: [
            // Inside your Column widget:
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(active ? 'Developer Active' : 'Developer Inactive',
                    style: TextStyle(fontSize: 16)),
                Switch(
                  value: active,
                  onChanged: (value) {
                    if (!value) {
                      // If the switch is turned off, show confirmation dialog
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Confirm Deactivation"),
                            content: Text(
                                "Are you sure you want to deactivate this developer?"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("Cancel"),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the dialog
                                },
                              ),
                              TextButton(
                                child: Text("Confirm"),
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Dismiss the dialog
                                  setState(() {
                                    active = value; // Change the active status
                                    toggleDeveloperStatus(
                                        value); // Update the Firestore document
                                  });
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      // If the switch is turned on, no confirmation is needed, just toggle the status
                      setState(() {
                        active = value;
                        toggleDeveloperStatus(
                            value); // Update the Firestore document
                      });
                    }
                  },
                ),
              ],
            ),

            active
                ? DropdownButtonFormField<String>(
                    value: selectedProjectId,
                    items: menuItems,
                    elevation: 1,
                    onChanged: (value) {
                      setState(() {
                        selectedProjectId = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Select a Project',
                    ),
                  )
                : Container(),
            SizedBox(
              height: height * 0.02,
            ),
            active
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAssigningProject
                            ? 'Assign to Project '
                            : 'Remove from Project',
                        style: TextStyle(fontSize: 16),
                      ),
                      SwitcherButton(
                        onColor: const Color(0xFF974061),
                        offColor: Colors.black,
                        value: isAssigningProject,
                        onChange: (value) {
                          setState(() {
                            isAssigningProject = value;
                          });
                        },
                      ),
                      // Text('Remove ')
                    ],
                  )
                : Container(),
            SizedBox(
              height: height * 0.02,
            ),
            active
                ? ElevatedButton(
                    onPressed: toggleAction,
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                            Size(width * 0.65, height * 0.006)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    child: Text(isAssigningProject ? 'Confirm' : 'Confirm',
                        style: const TextStyle(color: Colors.white)),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
