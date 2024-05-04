import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_management_app/admin/projectDetails.dart';
import 'package:project_management_app/screens/home.dart';
import '../widgets/progressIndicator.dart';
import 'addProject.dart';

class AdminProjectView extends StatefulWidget {
  const AdminProjectView({super.key});

  @override
  State<AdminProjectView> createState() => _AdminProjectViewState();
}

class _AdminProjectViewState extends State<AdminProjectView> {
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = _searchController.text.toLowerCase();
    });
  }

  Stream<QuerySnapshot> _projectStream() {
    return _firestore.collection('Clients').snapshots();
  }

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
      appBar:AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProject()));
            },
          ),
        ],
      ),

      body: Container(
        margin: EdgeInsets.symmetric(horizontal:width*0.1),
        child: StreamBuilder<QuerySnapshot>(
          stream:  _projectStream() ,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CustomProgressIndicator());
            }


            final filteredDocs = searchQuery.isEmpty
                ? snapshot.data!.docs
                : snapshot.data!.docs.where((doc) => doc.id.toLowerCase().contains(searchQuery)).toList();

            return ListView.builder(
              itemCount: filteredDocs.length,
              itemBuilder: (context, index) {
                return Container(
                decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(width: 1.0, color: Colors.grey)),
                ),
                  child: ListTile(
                    title: Text(filteredDocs[index].id),
                    onTap: (){
                      print("here");
                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ProjectDetails(projectId: filteredDocs[index].id)));
                    },

                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }
}
