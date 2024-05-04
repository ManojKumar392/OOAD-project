import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_management_app/repository/project_repository.dart';
import 'package:project_management_app/screens/home.dart';
import 'package:switcher_button/switcher_button.dart';

import '../widgets/progressIndicator.dart';

class AddProject extends StatefulWidget {
  const AddProject({Key? key}) : super(key: key);

  @override
  State<AddProject> createState() => _AddProjectState();
}

class _AddProjectState extends State<AddProject> {
  final _formKey = GlobalKey<FormState>();
  bool isAssigningProject = true;

  bool active = true;
  DateTime? dueDate;
  double? timeLeft;
  List<MapEntry<TextEditingController, TextEditingController>> workEntries = [];

  TextEditingController _dueDateController = TextEditingController();
  TextEditingController _timeLeftController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dueDateController.text = "";
    _timeLeftController.text = "";
    _nameController.text = "";
  }

  @override
  void dispose() {
    _dueDateController.dispose();
    _timeLeftController.dispose();
    _nameController.dispose();
    for (var entry in workEntries) {
      entry.key.dispose();
      entry.value.dispose();
    }
    super.dispose();
  }

  bool _isSubmitting = false;
  bool get _isLastEntryValid {
    if (workEntries.isEmpty) return true;
    var lastEntry = workEntries.last;
    return lastEntry.key.text.isNotEmpty &&
        double.tryParse(lastEntry.value.text) != null;
  }

  void _pickDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != dueDate) {
      setState(() {
        dueDate = picked;
        _dueDateController.text = DateFormat('MMM d, yyyy').format(picked);
      });
    }
  }

  void _addNewWorkEntry() {
    setState(() {
      workEntries
          .add(MapEntry(TextEditingController(), TextEditingController()));
    });
  }

  void _removeWorkEntry(
      MapEntry<TextEditingController, TextEditingController> entry) {
    entry.key.dispose();
    entry.value.dispose();
    setState(() {
      workEntries.remove(entry);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      Map<String, dynamic> projectData = {
        'name': name,
        'active': active,
        'dueDate': dueDate?.toIso8601String(),
        'timeLeft': double.tryParse(_timeLeftController.text),
        'work': {},
      };

      for (var entry in workEntries) {
        String category = entry.key.text;
        double hours = double.tryParse(entry.value.text) ?? 0.0;
        projectData['work'][category] = hours;
      }

      try {
        ProjectRepository().createProject(projectData).then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const Home()));
        });
        setState(() {
          _isSubmitting = false;
        });

        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Success',
            message: 'Project added successfully!',
            contentType: ContentType.success,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      } catch (e) {
        setState(() {
          _isSubmitting = false;
        });

        final snackBar = SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error',
            message: 'Failed to add project: $e',
            contentType: ContentType.failure,
          ),
        );
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Project'),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: width * 0.03),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Project Title',
                  ),
                ),
                SizedBox(
                  height: height * 0.03,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isAssigningProject ? 'Active' : 'Inactive',
                      style: TextStyle(fontSize: 18),
                    ),
                    SwitcherButton(
                      onColor: Color(0xFF974061),
                      offColor: Colors.black,
                      value: isAssigningProject,
                      onChange: (bool value) {
                        setState(() {
                          active = value;
                        });
                      },
                    ),
                  ],
                ),
                TextFormField(
                  controller: _dueDateController,
                  decoration: InputDecoration(
                    labelText: 'Due Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _pickDueDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select due date';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _timeLeftController,
                  decoration: InputDecoration(labelText: 'Time Left'),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter time left';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    timeLeft = double.tryParse(value ?? '');
                  },
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLastEntryValid ? _addNewWorkEntry : null,
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                            Size(width * 0.8, height * 0.006)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    child: const Text(
                      'Add Work Category + ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                ...workEntries.map((entry) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: entry.key,
                          decoration:
                              InputDecoration(labelText: 'Work Category'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter category name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: entry.value,
                          decoration: InputDecoration(labelText: 'Hours'),
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter hours';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeWorkEntry(entry),
                      ),
                    ],
                  );
                }).toList(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: _isSubmitting
                        ? CustomProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitForm,
                            child: Text(
                              'Submit',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ButtonStyle(
                                fixedSize: MaterialStateProperty.all(
                                    Size(width * 0.5, height * 0.006)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.black)),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
