import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_management_app/repository/project_repository.dart';
import 'package:switcher_button/switcher_button.dart';

import '../widgets/progressIndicator.dart';

class ProjectDetails extends StatefulWidget {
  final String projectId;

  const ProjectDetails({Key? key, required this.projectId}) : super(key: key);

  @override
  _ProjectDetailsState createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  final _formKey = GlobalKey<FormState>();
  bool isAssigningProject = true;

  bool _isActive = false;
  DateTime? _dueDate;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();
  TextEditingController _timeLeftController = TextEditingController();
  List<TextEditingController> _categoryControllers = [];
  List<TextEditingController> _hoursControllers = [];

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchProjectDetails();
  }

  void _addCategoryField() {
    setState(() {
      _categoryControllers.add(TextEditingController());
      _hoursControllers.add(TextEditingController());
    });
  }

  void _removeCategoryField(int index) {
    setState(() {
      _categoryControllers.removeAt(index);
      _hoursControllers.removeAt(index);
    });
  }

  Future<void> _fetchProjectDetails() async {
    try {
      print(widget.projectId);

      final projectData =
          await ProjectRepository().getProjectDetails(widget.projectId);
      print(projectData);
      setState(() {
        _isActive = projectData['active'] ?? false;
        String dueDateString = projectData['dueDate'];
        _dueDate = DateTime.parse(dueDateString);
        _dueDateController.text = DateFormat('MMM d, yyyy').format(_dueDate!);
        _timeLeftController.text = projectData['timeLeft'].toString();
        _nameController.text = widget.projectId;
        projectData['work'].forEach((category, hours) {
          _categoryControllers.add(TextEditingController(text: category));
          _hoursControllers.add(TextEditingController(text: hours.toString()));
        });
        print("here2");
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching project details: $e');
      _isLoading = false;
    }
  }

  Future<void> _updateProjectDetails() async {
    setState(() {
      _isSubmitting = true;
    });

    print("here2");
    Map<String, dynamic> updatedData = {
      'active': _isActive,
      'dueDate': _dueDate?.toIso8601String(),
      'timeLeft': double.tryParse(_timeLeftController.text),
      'work': {},
      "name": widget.projectId
    };
    double sum = 0;
    for (int i = 0; i < _categoryControllers.length; i++) {
      String category = _categoryControllers[i].text;
      double hours = double.tryParse(_hoursControllers[i].text) ?? 0;
      updatedData['work'][category] = hours;
      sum += hours;
    }
    updatedData['timeLeft'] = sum;

    await ProjectRepository().updateProject(updatedData).then((value) {
      setState(() {
        _isSubmitting = false;
      });
    }).catchError((e) {
      final snackBar = SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Error',
          message: 'Failed to update project: $e',
          contentType: ContentType.failure,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
      setState(() {
        _isSubmitting = false;
      });
    });

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Success',
        message: 'Project updated successfully:',
        contentType: ContentType.success,
      ),
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Project Details'),
      ),
      body: _isLoading
          ? Center(child: CustomProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    readOnly: true,
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Project Name'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter project name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isActive ? "Active" : "Inactive",
                        style: TextStyle(fontSize: 18),
                      ),
                      SwitcherButton(
                        onColor: const Color(0xFF974061),
                        offColor: Colors.black,
                        value: _isActive,
                        onChange: (value) {
                          setState(() {
                            _isActive = value;
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
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (picked != null && picked != _dueDate) {
                        setState(() {
                          _dueDate = picked;
                          _dueDateController.text =
                              DateFormat('MMM d, yyyy').format(picked);
                        });
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a due date';
                      }
                      return null;
                    },
                  ),
                  Row(
                    children: [
                      const Text(
                        "Work Categories",
                        style: TextStyle(fontSize: 18),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          icon: Icon(Icons.add),
                          color: Colors.black,
                          iconSize: 30.0,
                          onPressed: _addCategoryField,
                          tooltip: 'Add Category',
                        ),
                      )
                    ],
                  ),
                  TextFormField(
                    controller: _timeLeftController,
                    readOnly: true,
                    decoration:
                        const InputDecoration(labelText: 'Time Left (hours)'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter time left';
                      }
                      return null;
                    },
                  ),
                  ...List.generate(_categoryControllers.length, (index) {
                    return Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _categoryControllers[index],
                            decoration: InputDecoration(labelText: 'Category'),
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
                            controller: _hoursControllers[index],
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
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => _removeCategoryField(index),
                        ),
                      ],
                    );
                  }),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                            Size(width * 0.5, height * 0.006)),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.black)),
                    child: const Text(
                      "Update",
                      style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
                    onPressed: _updateProjectDetails,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dueDateController.dispose();
    _timeLeftController.dispose();
    _categoryControllers.forEach((controller) => controller.dispose());
    _hoursControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
