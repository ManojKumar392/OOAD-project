import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:project_management_app/repository/api_repository.dart';

import 'end_points.dart';

class ProjectRepository {
  final ApiService apiService = ApiService();

  Future<void> createProject(Map<String, dynamic> projectDetails) async {
    try {
      final response = await apiService.post(CREATE_PROJECT, projectDetails);
      if (response.statusCode == 200) {
        debugPrint('Project created successfully: ${response.body}');
      } else {
        throw Exception('Failed to create project: ${response.body}');
      }
    } catch (e) {
      print('Error creating project: $e');
    }
  }

  Future<List> getAllProjects() async {
    try {
      final response = await apiService.get(GET_ALL_PROJECTS);
      if (response.statusCode == 200) {
        print('Projects: ${response.body}');
        List projects = jsonDecode(response.body);
        return projects;
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting projects: $e');
      return [];
    }
  }

  Future assignDeveloper(String projectID, String userUID) async {
    final data = {
      'projectId': projectID,
      'userUID': userUID,
    };
    try {
      final response = await apiService.post(ASSIGN_DEVELOPER, data);
      if (response.statusCode == 200) {
        debugPrint('Developer assigned successfully: ${response.body}');
      } else {
        throw Exception('Failed to assign developer: ${response.body}');
      }
    } catch (e) {
      print('Error assigning developer: $e');
    }
  }

  Future<Map> getProjectDetails(String projectId) async {
    final data = {
      'projectId': projectId,
    };

    try {
      final response = await apiService.post(PROJECT_DETAILS, data);
      if (response.statusCode == 200) {
        Map projectDetails = jsonDecode(response.body);
        return projectDetails;
      } else {
        throw Exception('Failed to get project details: ${response.body}');
      }
    } catch (e) {
      print('Error getting project details: $e');
      return {};
    }
  }

  Future<void> updateProject(Map<String, dynamic> projectDetails) async {
    try {
      final response = await apiService.post(UPDATE_PROJECT, projectDetails);
      if (response.statusCode == 200) {
        debugPrint('Project updated successfully: ${response.body}');
      } else {
        throw Exception('Failed to update project: ${response.body}');
      }
    } catch (e) {
      print('Error updating project: $e');
    }
  }

  Future<void> deactivateProject(String projectId, String userUID) async {
    final data = {
      'projectId': projectId,
      'userUID': userUID,
    };
    try {
      final response = await apiService.post(DEACTIVATE_PROJECT, data);
      if (response.statusCode == 200) {
        debugPrint('Project deactivated successfully: ${response.body}');
      } else {
        throw Exception('Failed to deactivate project: ${response.body}');
      }
    } catch (e) {
      print('Error deactivating project: $e');
    }
  }
}
