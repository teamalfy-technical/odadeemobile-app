import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odadee/config/api_config.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/services/auth_service.dart';

class ProjectService {
  final AuthService _authService = AuthService();

  Future<List<Project>> getPublicProjects() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.publicProjectsEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> projectsJson = data['projects'] ?? [];
        return projectsJson.map((p) => Project.fromJson(p)).toList();
      }
      throw Exception('Failed to load public projects');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Project>> getAllProjects() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        ApiConfig.projectsEndpoint,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> projectsJson = data['projects'] ?? [];
        return projectsJson.map((p) => Project.fromJson(p)).toList();
      }
      throw Exception('Failed to load projects');
    } catch (e) {
      rethrow;
    }
  }

  Future<Project> getProjectDetails(String projectId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '${ApiConfig.projectsEndpoint}/$projectId',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Project.fromJson(data['project']);
      }
      throw Exception('Project not found');
    } catch (e) {
      rethrow;
    }
  }
}
