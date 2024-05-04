import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_management_app/admin/assignProject.dart';
import 'package:project_management_app/admin/projectDetails.dart';
import 'package:project_management_app/widgets/progressIndicator.dart';

class AdminDeveloperView extends StatefulWidget {
  const AdminDeveloperView({Key? key}) : super(key: key);

  @override
  State<AdminDeveloperView> createState() => _AdminDeveloperViewState();
}

class _AdminDeveloperViewState extends State<AdminDeveloperView> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  String dropdownValue = 'Active';

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

  Stream<QuerySnapshot> _usersStream(String filter) {
    if (filter == 'All') {
      return FirebaseFirestore.instance.collection('Users').snapshots();
    } else {
      bool isActive = filter == 'Active';
      if(isActive!=false)
        {

          return FirebaseFirestore.instance
              .collection('Users')
              .where('isActive', isNotEqualTo: false)
              .snapshots();
        }
      else
        {
          return FirebaseFirestore.instance
              .collection('Users')
              .where('isActive', isEqualTo: false)
              .snapshots();
        }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.grey),
              ),
            ),
            DropdownButton<String>(
              elevation: 0,

              value: dropdownValue,
              onChanged: (String? newValue) {
                setState(() {
                  dropdownValue = newValue!;
                });
              },
              items: <String>['Active', 'Inactive', 'All']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream(dropdownValue),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CustomProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No developers found.'));
          }

          List<DocumentSnapshot> userDocs = snapshot.data!.docs.where((doc) {
            return searchQuery.isEmpty ||
                doc['Name'].toLowerCase().contains(searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              var userData = userDocs[index].data() as Map<String, dynamic>;
              return ListTile(
                onTap: (){
                  print("aaaaa ${userDocs[index].id}");
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>AssignProject(developerId: userDocs[index].id, )));},
                title: Text(userData['Name']),
                subtitle: Text(userData['isActive']==null ? 'Active' :userData['isActive']?'Active':'Inactive'),
              );
            },
          );
        },
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
