import 'dart:convert';

import 'package:project_management_app/repository/api_repository.dart';

import 'end_points.dart';

class DeveloperRepository {
  final ApiService apiService = ApiService();

  Future<void> reportWork(Map<String, dynamic> reportWorkData) async {
    try {
      final response = await apiService.post(REPORT_WORK, reportWorkData);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to report work');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getWorkedHours(String userUID) async {
    try {
      Map<String, dynamic> data = {'userUID': userUID};
      final response = await apiService.post(WORKED_HOURS, data);
      if (response.statusCode == 200) {
        final hours = jsonDecode(response.body);
        ;
        print("#### $hours");
        return hours;
      } else {
        throw Exception('Failed to report work');
      }
    } catch (e) {
      rethrow;
    }
  }
}
