import 'dart:convert';

import 'package:project_management_app/repository/api_repository.dart';

import 'end_points.dart';

class FeedbackRepository {
  final ApiService apiService = ApiService();

  Future<void> addFeedback(Map<String, dynamic> feedback) async {
    try {
      final response = await apiService.post(CREATE_FEEDBACK, feedback);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to add feedback');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List> getFeedbacks() async {
    try {
      final response = await apiService.get(GET_FEEDBACK);
      if (response.statusCode == 200) {
        final feedbacks = jsonDecode(response.body);
        print("#### $feedbacks");
        return feedbacks;
      } else {
        throw Exception('Failed to get feedbacks');
      }
    } catch (e) {
      rethrow;
    }
  }
}
