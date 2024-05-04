import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_management_app/admin/assignProject.dart';
import 'package:project_management_app/admin/projectDetails.dart';
import 'package:project_management_app/repository/project_repository.dart';
import 'package:project_management_app/widgets/progressIndicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../admin/addAdmin.dart';
import '../admin/addProject.dart';
import '../admin/viewFeedback.dart';
import '../screens/feedback.dart';
import '../screens/login.dart';
import '../screens/profile.dart';
import '../screens/work.dart';

class AdminWeb extends StatefulWidget {
  const AdminWeb({super.key});

  @override
  State<AdminWeb> createState() => _AdminWebState();
}

class _AdminWebState extends State<AdminWeb> {
  bool getOnlyActive = true;
  TextEditingController searchController = TextEditingController();
  String dropdownValue = 'Developer'; // Default value for dropdown
  String searchQuery = ''; // The current search query
  final _scrollController1 = ScrollController();
  final _scrollController2 = ScrollController();
  late Stream<QuerySnapshot> clientStream;
  late Stream<QuerySnapshot> developerStream;
  String developerFilter =
      'All'; // Possible values: 'All', 'Active', 'Inactive'
  late Stream<QuerySnapshot> generalStream;
  String filter = "";
  void initState() {
    clientStream = FirebaseFirestore.instance
        .collection('Clients')
        .where('isActive', isEqualTo: true)
        .snapshots();
    developerStream =
        FirebaseFirestore.instance.collection('users').snapshots();
    searchController.addListener(() {
      setState(() {
        filter = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _scrollController2.dispose();
    _scrollController1.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> getDeveloperStream() {
    // This stream will get all developers or those that match the search query
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('users');
    if (searchQuery.isNotEmpty) {
      query = query
          .where('name', isGreaterThanOrEqualTo: searchQuery)
          .where('name', isLessThanOrEqualTo: searchQuery + '\uf8ff');
    }
    return query.snapshots();
  }

  Stream<QuerySnapshot> getFilteredDeveloperStream(String filter) {
    Query query = FirebaseFirestore.instance.collection('users');
    if (filter == 'Active') {
      query = query.where('active', isEqualTo: true);
    } else if (filter == 'Inactive') {
      query = query.where('active', isEqualTo: false);
    }
    // No additional filtering for 'All'
    return query.snapshots();
  }

  Stream<QuerySnapshot> getClientStream() {
    // If there is no search query, return all clients.
    if (searchQuery.isEmpty) {
      return FirebaseFirestore.instance.collection('Clients').snapshots();
    } else {
      // If there is a search query, create a stream that looks for a specific document by ID.
      // This will return a stream with a single document if it exists.
      return FirebaseFirestore.instance
          .collection('Clients')
          .where(FieldPath.documentId, isEqualTo: searchQuery)
          .snapshots();
    }
  }

  Future<void> ActiveInactiveDeveloper(
      bool isActive, String developerId) async {
    try {
      DocumentReference developerRef =
          FirebaseFirestore.instance.collection("users").doc(developerId);

      // Perform the update operation
      await developerRef
          .set({'active': !isActive}, SetOptions(merge: true)).then((_) {
        print("done");
      }).onError((error, stackTrace) => throw error.toString());
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              SizedBox(
                  width:
                      10), // Give some space between the logo and the search bar
              Expanded(
                child: DropdownButtonFormField<String>(
                  elevation: 0,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(23.0)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 15), // Adjust padding as needed
                  ),
                  hint: Text(
                    dropdownValue,
                    style: GoogleFonts.poppins(
                      color: Colors.black, // Text color for hint
                      fontWeight:
                          FontWeight.w500, // Choose the weight of the font
                    ),
                  ),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        dropdownValue = newValue;
                        if (newValue == 'Developer') {
                          developerStream =
                              getFilteredDeveloperStream(developerFilter);
                        } else if (newValue == 'Client') {
                          clientStream =
                              getClientStream(); // This should update the client stream
                        }
                      });
                    }
                  },

                  style: GoogleFonts.poppins(
                    color: Colors.black, // Text color inside the dropdown
                  ),
                  dropdownColor:
                      Colors.white, // Background color for the dropdown items
                  items: <String>['Developer', 'Client']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        child: Text(
                          value,
                          style: GoogleFonts.poppins(
                            color: Colors.black, // Text color for items
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(width: 10), // Space between dropdown and search bar
              Flexible(
                flex: 3,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value; // Update the search query
                    });
                  },
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (String result) {
                switch (result) {
                  case 'addAdmin': // This must match the PopupMenuEntry value
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddAdmin()),
                    );
                    break;
                  case 'addClient': // This must match the PopupMenuEntry value

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddProject(),
                      ),
                    );
                    break;
                  case 'viewFeedback':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewFeedback(),
                      ),
                    );
                    break;
                  case 'viewReportedWork':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkScreen(),
                      ),
                    );
                    break;
                  case 'changeActive':
                    setState(() {
                      getOnlyActive = !getOnlyActive;
                    });
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'addAdmin',
                  child: Text('Add Admin'),
                ),
                const PopupMenuItem<String>(
                  value: 'addClient',
                  child: Text('Add Client View'),
                ),
                const PopupMenuItem<String>(
                  value: 'viewFeedback',
                  child: Text('View Feedback'),
                ),
                const PopupMenuItem<String>(
                  value: 'viewReportedWork',
                  child: Text('View Reported Work'),
                ),
                PopupMenuItem<String>(
                  value: 'changeActive',
                  child: Text(getOnlyActive ? 'Show All' : 'Show only Active'),
                )
              ],
            )
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: width * 0.01) // No margin for web
            , // Margin for other platforms
            child: ListView(
              padding: EdgeInsets.only(top: height * 0.07),
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1.0, color: Color(0xFFEEEAEA))),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.person_outline, color: Colors.black),
                        SizedBox(width: width * 0.06),
                        Expanded(
                          // Wrap Text with Expanded to prevent overflow
                          child: Text('Profile'),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen()));
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1.0, color: Color(0xEEEAEAFF))),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.feed_outlined, color: Colors.black),
                        SizedBox(
                          width: width * 0.06,
                        ),
                        Text('Feedback'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FeedbackScreen()));
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom:
                            BorderSide(width: 1.0, color: Color(0xEEEAEAFF))),
                  ),
                  child: ListTile(
                    title: Row(
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.black),
                        SizedBox(
                          width: width * 0.06,
                        ),
                        Text('Logout'),
                      ],
                    ),
                    onTap: () async {
                      FirebaseAuth.instance.signOut().then((value) async {
                        SharedPreferences pref =
                            await SharedPreferences.getInstance();
                        pref.remove("email");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignIn()));
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: getOnlyActive
              ? FirebaseFirestore.instance
                  .collection('Clients')
                  .where('active', isEqualTo: true)
                  .snapshots()
              : FirebaseFirestore.instance.collection('Clients').snapshots(),
          builder: (context, clientSnapshot) {
            if (clientSnapshot.hasError) {
              return Text('Error: ${clientSnapshot.error}');
            }
            if (clientSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CustomProgressIndicator());
            }
            var activeClients = getOnlyActive
                ? clientSnapshot.data!.docs
                    .where((doc) => doc['active'] as bool)
                    .toList()
                : clientSnapshot.data!.docs.toList();

            return StreamBuilder<QuerySnapshot>(
              stream: developerStream,
              builder: (context, developerSnapshot) {
                if (developerSnapshot.hasError) {
                  return Text('Error: ${developerSnapshot.error}');
                }
                if (developerSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CustomProgressIndicator());
                }

                var developers = developerSnapshot.data!.docs;
                if (filter.isNotEmpty) {
                  developers = developers.where((doc) {
                    return (doc.data() as Map<String, dynamic>)['name']
                        .toString()
                        .toLowerCase()
                        .contains(filter.toLowerCase());
                  }).toList();
                }

                return ScrollbarTheme(
                  data: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(Color(0xFF974061)),
                    crossAxisMargin: 2,
                    mainAxisMargin: 2,
                    radius: Radius.circular(10),
                    thickness: MaterialStateProperty.all(10),
                  ),
                  child: Scrollbar(
                    controller: _scrollController2,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _scrollController2,
                      scrollDirection: Axis.vertical,
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor:
                              MaterialStateProperty.all(Color(0xFF974061)),
                          crossAxisMargin: 2,
                          mainAxisMargin: 2,
                          radius: Radius.circular(10),
                          thickness: MaterialStateProperty.all(10),
                        ),
                        child: Scrollbar(
                          controller: _scrollController1,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollController1,
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 20),
                              child: DataTable(
                                columns: getColumns(activeClients),
                                rows: getRows(developers, activeClients),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<DataColumn> getColumns(List<DocumentSnapshot> clients) {
    List<DataColumn> columns = [
      DataColumn(
        label: Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(23.0)),
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 7, vertical: 15), // Adjust padding as needed
            ),
            value: developerFilter,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  developerFilter = newValue;

                  developerStream = getFilteredDeveloperStream(newValue);
                });
              }
            },
            items: <String>['All', 'Active', 'Inactive']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ),
      ),
    ];
    for (var client in clients) {
      // print("clients:${client.id}");
      columns.add(DataColumn(
          label: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          child: Text(
            client.id,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProjectDetails(projectId: client.id)));
          },
        ),
      )));
    }

    ;
    return columns;
  }

  List<DataRow> getRows(
      List<DocumentSnapshot> developers, List<DocumentSnapshot> clients) {
    return developers.map((developer) {
      bool isActiveDeveloper =
          (developer.data() as Map<String, dynamic>).containsKey('active')
              ? developer['active'] as bool
              : true;

      List<DataCell> cells = [
        DataCell(
          GestureDetector(
            onTap: isActiveDeveloper
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AssignProject(
                                  developerId: developer.id,
                                )));
                  }
                : null,
            child: Row(
              children: [
                Text(
                  developer['name'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActiveDeveloper ? Colors.black : Colors.grey,
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      final popupText = isActiveDeveloper
                          ? 'make developer ${developer['name']} inactive'
                          : 'make developer ${developer['name']} active';
                      final confirm = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm'),
                                content: Text(
                                    'Are you sure you want to $popupText ?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          false); // Will not change assigned status
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Confirm'),
                                    onPressed: () {
                                      Navigator.of(context).pop(
                                          true); // Will change assigned status
                                    },
                                  ),
                                ],
                              );
                            },
                          ) ??
                          false;
                      if (confirm) {
                        await ActiveInactiveDeveloper(
                            isActiveDeveloper, developer.id);
                        setState(() {
                          isActiveDeveloper = !isActiveDeveloper;
                          print(isActiveDeveloper);
                        });
                      }
                    },
                    icon: isActiveDeveloper
                        ? Icon(
                            Icons.remove_circle_outline,
                            color: Colors.red,
                          )
                        : Icon(Icons.add_circle_outline,
                            color: Colors.greenAccent))
              ],
            ),
          ),
        )
      ];
      //  print("developer name");
//print(developer['Name']);
      for (var client in clients) {
        bool assigned = developer['projectsAlloted'] != null &&
            (developer['projectsAlloted'] as List).contains(client.id);
        bool isAssigned = developer['projectsAlloted'] != null &&
            developer['projectsAlloted'].contains(client.id);

        cells.add(DataCell(
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(child: child, scale: animation);
            },
            child: isAssigned
                ? Icon(Icons.check,
                    key: ValueKey<bool>(isAssigned), color: Color(0xFF974061))
                : Icon(Icons.close, key: ValueKey<bool>(isAssigned)),
          ),
          onTap: () async {
            bool isactive = developer['active'] ?? false;
            if (isactive == true) {
              final popupText = assigned
                  ? 'remove ${developer['name']} from ${client.id}'
                  : 'add ${developer['name']} to ${client.id}';
              final confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm'),
                        content: Text('Are you sure you want to $popupText ?'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(
                                  false); // Will not change assigned status
                            },
                          ),
                          TextButton(
                            child: Text('Confirm'),
                            onPressed: () {
                              Navigator.of(context)
                                  .pop(true); // Will change assigned status
                            },
                          ),
                        ],
                      );
                    },
                  ) ??
                  false; // In case the dialog is dismissed

              if (confirm) {
                if (assigned) {
                  // Logic to remove the client from developer's allotted list
                  unassignClientFromDeveloper(developer.id, client.id);
                } else {
                  // Logic to add the client to developer's allotted list
                  assignClientToDeveloper(developer.id, client.id);
                }
                // Trigger the state change to update the UI
                setState(() {
                  assigned = !assigned;
                });
              }
            } else {
              final snackBar = SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error',
                  message: "Activate developer to add to project",
                  contentType: ContentType.failure,
                ),
              );

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(snackBar);
            }
          },
        ));
      }

      return DataRow(cells: cells);
    }).toList();
  }

  void assignClientToDeveloper(String developerId, String projectId) {
    ProjectRepository().assignDeveloper(projectId, developerId).then((value) {
      SnackBar snackBar = const SnackBar(
        content: Text('Developer assigned successfully!'),
      );
    });
  }

  void unassignClientFromDeveloper(String developerId, String clientId) {
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference developerRef =
          FirebaseFirestore.instance.collection('users').doc(developerId);

      DocumentSnapshot developerSnapshot = await transaction.get(developerRef);

      if (!developerSnapshot.exists) {
        throw Exception("Developer does not exist!");
      }

      List<dynamic> projectsAlloted =
          List.from(developerSnapshot['projectsAlloted'] ?? []);
      projectsAlloted.remove(clientId);
      transaction.update(developerRef, {'projectsAlloted': projectsAlloted});
    });
  }
}
