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
  @override
  _ProjectsScreenState createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  List projectList = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();

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
      body: SafeArea(
        bottom: false,
        child: Container(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: odaSecondary,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Projects (" +
                                  projectList.length.toString() +
                                  ")",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ],
                        ),
                        Stack(
                          children: [
                            Icon(
                              Icons.notifications_none_outlined,
                              color: odaSecondary,
                              size: 30,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                backgroundColor: odaSecondary,
                                radius: 5,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: projectList.length,
                        itemBuilder: (context, index) {
                          final projectItem = projectList[index];
                          return Container(
                            margin: EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              projectItem.image!..toString()),
                                          fit: BoxFit.cover)),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  projectItem.title!.toString(),
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  projectItem.content!.toString(),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        ProjectDetailsScreen(
                                                            data:
                                                                projectItem)));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        width: 150,
                                        decoration: BoxDecoration(
                                            color: odaPrimary,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        child: Center(
                                          child: Text(
                                            "View Project",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Ghc " +
                                          projectItem.fundingTarget!.toString(),
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: odaSecondary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 75,
                  )
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          /*      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()));
                      */
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.home,
                              color: odaSecondary,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Home',
                              style:
                                  TextStyle(color: odaSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RadioScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(Icons.radio, color: Colors.grey),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Radio',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  PayDuesScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.phone_android,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Pay Dues',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SettingsScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Settings',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  UserProfileScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Profile',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
