import 'package:flutter/material.dart';

import '../repository/work_controller.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({super.key});

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reported Work'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FutureBuilder<List>(
              future: WorkRepository()
                  .getReportedWorks(), // Assuming this is your method that returns a Future<List<Map<String, dynamic>>>
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show a loading indicator while waiting
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}'); // Show error if any
                } else {
                  // Build a list view with the data
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> item = snapshot.data![index];
                      return ListTile(
                        title: Column(
                          children: [
                            Text(item['Client']),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(item['Description']),
                                Text(item['Hours'].toString()),
                                Text("User ${item['uid'].toString()}")
                              ],
                            ),
                            Divider(
                              color: Colors.black,
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
