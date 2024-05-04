import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:flutter/material.dart';
import 'package:project_management_app/admin/adminHome.dart';
import 'package:project_management_app/developer/developerHome.dart';
import 'package:project_management_app/repository/developer_repository.dart';
import 'package:project_management_app/screens/feedback.dart';
import 'package:project_management_app/screens/login.dart';
import 'package:project_management_app/screens/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/user_repository.dart';
import '../web/adminWeb.dart';
import '../widgets/progressIndicator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Stream<QuerySnapshot> clientStream;
  late Stream<QuerySnapshot> developerStream;
  bool _hasShownTip = false;
  bool dataLoaded = false;
  final user = FirebaseAuth.instance.currentUser;
  List<String> projectTitles = [];
  bool isAdmin = false;
  double totalHoursReported = 0;
  String message = "";
  bool hours = false;
  bool getOnlyActive = true;
  Future<void> fetchTotalHours() async {
    try {
      final double workedHours =
          await DeveloperRepository().getWorkedHours(user!.uid);
      if (mounted) {
        setState(() {
          totalHoursReported = workedHours;
          message = totalHoursReported.toString();
          hours = true;
        });
      }
    } catch (e) {
      print('Error fetching total hours: $e');
      setState(() {
        message = "Error: $e";
      });
    }
  }

  final player = AudioPlayer();
  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() async {
    await _checkIfAdmin(); // Make sure this method has 'await' for any async operations within it.
  }

  Future<void> _checkIfAdmin() async {
    if (user != null) {
      try {
        bool isAdminStatus = await UserRepository().getAdminStatus(user!.uid);
        if (mounted) {
          setState(() {
            isAdmin = isAdminStatus;
            dataLoaded = true;
          });
        }
      } catch (e) {
        print('Error fetching user document: $e');
        if (mounted) {
          setState(() {
            message = "Error: $e";
            dataLoaded = true;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          dataLoaded = true; // Move this here to ensure loading is completed
        });
      }
    }
  }

  Future<void> _showTipIfNeeded() async {
    if (!isAdmin && !_hasShownTip) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool hasSeenTip = prefs.getBool('hasSeenTip') ?? false;
      if (!hasSeenTip && !isAdmin) {
        await prefs.setBool('hasSeenTip', true);
        await player.play(AssetSource('bubble.mp3'));

        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Tip',
            message:
                'Click the "Total Hours" button to see the number of hours you have worked.',
            contentType: ContentType.help,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    bool mobileWeb = false;
    if (width < 500) {
      mobileWeb = true;
    }
    print(mobileWeb);
    print(width);
    return dataLoaded
        ? (kIsWeb && !mobileWeb && isAdmin
            ? const AdminWeb()
            : WillPopScope(
                onWillPop: () async => false,
                child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: AppBar(
                    backgroundColor: Colors.white,
                  ),
                  drawer: Drawer(
                    backgroundColor: Colors.white,
                    child: Container(
                      margin: kIsWeb
                          ? EdgeInsets.zero
                          : EdgeInsets.only(
                              right: width * 0.1, left: width * 0.05),
                      child: ListView(
                        padding: EdgeInsets.only(top: height * 0.07),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1.0, color: Color(0xFFEEEAEA))),
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.person_outline,
                                      color: Colors.black),
                                  SizedBox(width: width * 0.06),
                                  Expanded(
                                    child: Text(
                                      'Profile',
                                      style: TextStyle(color: Colors.black),
                                    ),
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
                                  bottom: BorderSide(
                                      width: 1.0, color: Color(0xEEEAEAFF))),
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.feed_outlined,
                                      color: Colors.black),
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
                                        builder: (context) =>
                                            FeedbackScreen()));
                              },
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      width: 1.0, color: Color(0xEEEAEAFF))),
                            ),
                            child: ListTile(
                              title: Row(
                                children: [
                                  Icon(Icons.logout_rounded,
                                      color: Colors.black),
                                  SizedBox(
                                    width: width * 0.06,
                                  ),
                                  Text('Logout'),
                                ],
                              ),
                              onTap: () async {
                                FirebaseAuth.instance
                                    .signOut()
                                    .then((value) async {
                                  SharedPreferences pref =
                                      await SharedPreferences.getInstance();
                                  pref.remove("email");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SignIn()));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  body: isAdmin ? AdminHome() : DeveloperHome(),
                  bottomNavigationBar: BottomAppBar(
                    child: isAdmin
                        ? Center(child: Text("Admin View"))
                        : Container(
                            height: 50.0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                    onPressed: fetchTotalHours,
                                    style: ButtonStyle(
                                        fixedSize: MaterialStateProperty.all(
                                            Size(width * 0.5, height * 0.006)),
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Colors.black)),
                                    child: const Text(
                                      "Total Hours: ",
                                      style: TextStyle(color: Colors.white),
                                    )),
                                !hours
                                    ? const Icon(Icons.card_giftcard)
                                    : Text(
                                        message,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17),
                                      ),
                              ],
                            ),
                          ),
                  ),
                ),
              ))
        : const Scaffold(
            body: Center(
              child: CustomProgressIndicator(),
            ),
          );
  }
}
