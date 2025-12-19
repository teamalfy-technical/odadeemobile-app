import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/models/all_projects_model.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Projects/project_details.dart';
import 'package:odadee/Screens/Radio/playing_screen.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List projectList = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchProjectsData(currentPage);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (currentPage < lastPage && !isLoading) {
        currentPage++;
        _fetchProjectsData(currentPage);
      }
    }
  }

  Future<void> _fetchProjectsData(int page) async {
    setState(() {
      isLoading = true;
    });

    try {
      print('===== FETCHING PROJECTS PAGE $page =====');
      final authService = AuthService();
      final response = await authService.authenticatedRequest('GET', '/api/projects?page=$page');

      print('Projects API Status: ${response.statusCode}');
      print('Projects API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final projectData = Projects.fromJson(data['projects']);

        setState(() {
          lastPage = projectData.lastPage!;
          projectList.addAll(projectData.data!);
          isLoading = false;
        });
        print('Projects loaded successfully: ${projectData.data!.length} items');
      } else {
        throw Exception('Failed to load projects. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load projects. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _fetchProjectsData(page),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0f172a),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Projects (${projectList.length})',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Stack(
              children: [
                Icon(Icons.notifications_none_outlined, color: Color(0xFFf4d03f), size: 30),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    backgroundColor: Color(0xFFf4d03f),
                    radius: 5,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: projectList.isEmpty && !isLoading
            ? Center(
                child: Container(
                  padding: EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Color(0xFF1e293b),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF334155),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.work_outline, size: 60, color: Color(0xFF64748b)),
                      SizedBox(height: 16),
                      Text(
                        'No projects available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF94a3b8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: projectList.length,
                padding: EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  final projectItem = projectList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(
                                builder:
                                    (BuildContext context) =>
                                        ProjectDetailsScreen(
                                            data:
                                                projectItem)));
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Color(0xFF1e293b),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF334155),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (projectItem.image != null && projectItem.image!.isNotEmpty)
                              Container(
                                height: 180,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          projectItem.image!.toString()),
                                      fit: BoxFit.cover),
                                  border: Border.all(
                                    color: Color(0xFFf4d03f),
                                    width: 1,
                                  ),
                                ),
                              ),
                            SizedBox(height: 15),
                            Text(
                              projectItem.title ?? 'Untitled Project',
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 8),
                            Text(
                              projectItem.content ?? '',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF94a3b8)),
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Color(0xFF2563eb),
                                      borderRadius:
                                          BorderRadius.circular(8)),
                                  child: Text(
                                    "View Details",
                                    style:
                                        TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (projectItem.fundingTarget != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Color(0xFFf4d03f),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      "GHc ${projectItem.fundingTarget}",
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFFf4d03f),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
