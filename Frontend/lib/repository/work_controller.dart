import 'dart:convert';

import 'package:project_management_app/repository/api_repository.dart';
import 'package:project_management_app/repository/end_points.dart';

class WorkRepository {
  final ApiService _apiService = ApiService();

  Future<List> getReportedWorks() async {
    try {
      final response = await _apiService.get(GET_WORK);
      if (response.statusCode == 200) {
        final works = jsonDecode(response.body);
        print("works $works");
        return works;
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting works: $e');
      return [];
    }
  }
}
