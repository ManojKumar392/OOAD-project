import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:project_management_app/repository/end_points.dart';

import 'api_repository.dart';

class UserRepository {
  final ApiService apiService = ApiService();
  Future<void> createUser(
      String userUID, String email, String name, String role) async {
    final data = {
      'userUID': userUID,
      'email': email,
      'name': name,
      'role': role,
      'isAdmin': false,
      'isActive': true,
      'projectsAlloted': [],
    };

    try {
      final response = await apiService.post(CREATE_ACCOUNT, data);
      if (response.statusCode == 200) {
        debugPrint('User created successfully: ${response.body}');
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  Future getAdminStatus(String userUID) async {
    try {
      final response = await apiService.get("$ADMIN_STATUS?userUID=$userUID");
      if (response.statusCode == 200) {
        Map role = jsonDecode(response.body);
        return role['isAdmin'];
      } else {
        return false;
      }
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  Future<bool> getActiveStatus(String userUID) async {
    try {
      final response = await apiService.get("$ACTIVE_STATUS?userUID=$userUID");
      if (response.statusCode == 200) {
        Map role = jsonDecode(response.body);
        return role['isActive'];
      } else {
        return false;
      }
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getProfileDetails(String userUID) async {
    try {
      final response = await apiService.get("/user/$userUID");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {};
      }
    } catch (e) {
      return {};
    }
  }
}
