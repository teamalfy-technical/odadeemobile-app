import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/AllUsers/all_users_screen.dart';
import 'package:odadee/Screens/AllUsers/models/all_users_model.dart';
import 'package:odadee/Screens/AllUsers/member_detail_page.dart';
import 'package:odadee/Screens/Articles/all_news_screen.dart';
import 'package:odadee/Screens/Members/members_screen.dart';
import 'package:odadee/Screens/Articles/models/all_articles_model.dart';
import 'package:odadee/Screens/Articles/news_details.dart';
import 'package:odadee/Screens/Events/event_details.dart';
import 'package:odadee/Screens/Events/events_list.dart';
import 'package:odadee/Screens/Events/models/events_model.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/models/all_projects_model.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Projects/project_details.dart';
import 'package:odadee/Screens/Projects/projects_screen.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/components/stat_card.dart';
import 'package:odadee/components/footer_nav.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';

import '../Authentication/SignIn/sgin_in_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<AllUsersModel> _fetchAllUsersData() async {
    try {
      final authService = AuthService();
      final response =
          await authService.authenticatedRequest('GET', '/api/users');

      print('===== USERS API RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('==============================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Decoded JSON: $jsonData');
        return AllUsersModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const SignInScreen()));
        }
        throw Exception('Session expired. Please sign in again.');
      } else {
        throw Exception('Failed to load users. Status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('Socket error: $e');
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on http.ClientException catch (e) {
      print('Client error: $e');
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on HttpException catch (e) {
      print('HTTP error: $e');
      throw Exception('Network error: Unable to connect to server.');
    } on FormatException catch (e) {
      print('Format error: $e');
      throw Exception('Invalid data received from server.');
    } catch (e) {
      print('Unexpected error in _fetchAllUsersData: $e');
      rethrow;
    }
  }

  Future<AllEventsModel> _fetchAllEventsData() async {
    try {
      final authService = AuthService();
      final response =
          await authService.authenticatedRequest('GET', '/api/events');

      if (response.statusCode == 200) {
        return AllEventsModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const SignInScreen()));
        }
        throw Exception('Session expired. Please sign in again.');
      } else {
        throw Exception('Failed to load events. Please try again.');
      }
    } on SocketException {
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on http.ClientException {
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on HttpException {
      throw Exception('Network error: Unable to connect to server.');
    } on FormatException {
      throw Exception('Invalid data received from server.');
    } on Exception {
      rethrow;
    }
  }

  Future<AllProjectsModel> _fetchAllProjectsData() async {
    try {
      final authService = AuthService();
      final response =
          await authService.authenticatedRequest('GET', '/api/projects');

      if (response.statusCode == 200) {
        return AllProjectsModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const SignInScreen()));
        }
        throw Exception('Session expired. Please sign in again.');
      } else {
        throw Exception('Failed to load projects. Please try again.');
      }
    } on SocketException {
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on http.ClientException {
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on HttpException {
      throw Exception('Network error: Unable to connect to server.');
    } on FormatException {
      throw Exception('Invalid data received from server.');
    } on Exception {
      rethrow;
    }
  }

  Future<AllArticlesModel?> _fetchAllArticlesData() async {
    try {
      final authService = AuthService();
      final response =
          await authService.authenticatedRequest('GET', '/api/discussions');

      print('===== DISCUSSIONS API RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print(
          'Response Body: ${response.body.substring(0, response.body.length < 200 ? response.body.length : 200)}...');
      print('====================================');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['discussions'] != null) {
          final discussionsList = jsonData['discussions'] as List;

          final articlesJson = {
            'news': {
              'data': discussionsList.map((discussion) {
                final content = discussion['content']?.toString() ?? '';
                final summary = content.isNotEmpty
                    ? content.substring(
                        0, content.length > 100 ? 100 : content.length)
                    : '';

                return {
                  'id': discussion['id']?.toString() ?? '0',
                  'title': discussion['title'] ?? '',
                  'slug': discussion['slug']?.toString() ?? '',
                  'content': content,
                  'summary': summary,
                  'video': '',
                  'image': '',
                  'userId': discussion['userId']?.toString() ?? '0',
                  'yeargroup': discussion['categoryId'] ?? 0,
                  'yearmonth': '',
                  'admin': '',
                  'sticky': '',
                  'homePage': '',
                  'createdTime': discussion['createdAt'] ?? '',
                };
              }).toList()
            }
          };

          return AllArticlesModel.fromJson(articlesJson);
        }
        return null;
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const SignInScreen()));
        }
        return null;
      } else {
        print('Failed to load discussions. Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching discussions (non-critical): $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _fetchStats() async {
    try {
      final authService = AuthService();
      final response =
          await authService.authenticatedRequest('GET', '/api/stats');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error fetching stats (non-critical): $e');
      return null;
    }
  }

  String? user_year_group;
  String? userName;
  String? userEmail;
  String? userClass;

  @override
  void initState() {
    get_user_year_group();
    _fetchCurrentUser();
    super.initState();
  }

  Future<void> get_user_year_group() async {
    final yearGroup = await getUserYearGroup();
    if (mounted) {
      setState(() {
        user_year_group = yearGroup;
      });
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final authService = AuthService();
      
      print('===== FETCHING CURRENT USER =====');
      final userData = await authService.getCurrentUser();
      
      if (userData == null) {
        print('ERROR: getCurrentUser returned null');
        return;
      }
      
      print('===== CURRENT USER DATA =====');
      print('Full userData: $userData');
      print('Keys in userData: ${userData.keys.toList()}');
      print('firstName: ${userData['firstName']}');
      print('first_name: ${userData['first_name']}');
      print('email: ${userData['email']}');
      print('yearGroup: ${userData['yearGroup']}');
      print('graduationYear: ${userData['graduationYear']}');
      print('==============================');
      
      if (mounted) {
        setState(() {
          final firstName = userData['firstName']?.toString() ?? 
                          userData['first_name']?.toString() ?? '';
          userName = firstName.isNotEmpty ? firstName : null;
          userEmail = userData['email']?.toString() ?? '';
          
          final yearGroup = userData['yearGroup']?.toString() ?? 
                          userData['year_group']?.toString() ?? 
                          userData['graduationYear']?.toString() ?? '';
          userClass = yearGroup.isNotEmpty ? 'Class of $yearGroup' : '';
          
          print('===== SET STATE COMPLETE =====');
          print('userName: $userName');
          print('userEmail: $userEmail');
          print('userClass: $userClass');
          print('==============================');
        });
      }
    } catch (e, stackTrace) {
      print('===== ERROR FETCHING CURRENT USER =====');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      print('========================================');
    }
  }

  Widget _buildEventDate(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) {
        return _buildDateFallback();
      }

      final dateInfo = extractDateInfo(dateString);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateInfo['day'].toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateInfo['month'].toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                dateInfo['year'].toString(),
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      );
    } catch (e) {
      print('Error parsing event date: $e');
      return _buildDateFallback();
    }
  }

  Widget _buildDateFallback() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.event, color: Colors.white, size: 32),
        SizedBox(width: 8),
        Text(
          'TBA',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            _fetchAllUsersData(),
            _fetchAllEventsData(),
            _fetchAllProjectsData(),
            _fetchAllArticlesData(),
            _fetchStats(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Loading dashboard data...")
                  ],
                ),
              );
            } else if (snapshot.hasError) {
              print('Dashboard error: ${snapshot.error}');
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 60),
                      SizedBox(height: 20),
                      Text(
                        'Error loading dashboard',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (snapshot.hasData) {
              final userData = snapshot.data![0] as AllUsersModel;

              final eventsData = snapshot.data![1] as AllEventsModel;

              final projectsData = snapshot.data![2] as AllProjectsModel;

              final articlesData = snapshot.data![3] as AllArticlesModel?;

              final statsData = snapshot.data![4] as Map<String, dynamic>?;

              print("===== STATS DATA =====");
              print(statsData);
              print("======================");

              // Check if critical data is null (users, events, projects are required)
              if (userData == null ||
                  eventsData == null ||
                  projectsData == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 60),
                      SizedBox(height: 20),
                      Text('Error: Unable to load required data'),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final int usersCount = userData.users?.data?.length ?? 0;
              final int eventsCount = eventsData.events?.data?.length ?? 0;
              final int projectsCount =
                  projectsData.projects?.data?.length ?? 0;
              final int discussionsCount =
                  articlesData?.news?.data?.length ?? 0;

              return SafeArea(
                bottom: false,
                child: Container(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.asset(
                                                  'assets/images/presec_logo.webp',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    userName != null && userName!.isNotEmpty
                                                        ? "Welcome back, $userName!" 
                                                        : "Welcome back!",
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 20,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  if (userEmail != null && userEmail!.isNotEmpty) ...[
                                                    SizedBox(height: 2),
                                                    Text(
                                                      userEmail!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF94a3b8),
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  if (userClass != null && userClass!.isNotEmpty) ...[
                                                    SizedBox(height: 2),
                                                    Text(
                                                      userClass!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Color(0xFF94a3b8),
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
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
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  StatCard(
                                    title: 'Total Members',
                                    value: '$usersCount',
                                    icon: Icons.people,
                                    subtitle: 'Registered alumni',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MembersScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  StatCard(
                                    title: 'Events',
                                    value: '$eventsCount',
                                    icon: Icons.event,
                                    subtitle: 'Upcoming events',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => EventsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  StatCard(
                                    title: 'Products',
                                    value: '$projectsCount',
                                    icon: Icons.card_giftcard,
                                    subtitle: 'In shop',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ProjectsScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  StatCard(
                                    title: 'Contributions',
                                    value: statsData != null
                                        ? 'GH¢ ${statsData['contributions'] ?? statsData['total_contributions'] ?? statsData['amount'] ?? statsData['total_amount'] ?? statsData['total_donations'] ?? 0}'
                                        : 'GH¢ 0',
                                    icon: Icons.payments,
                                    subtitle: 'Total raised',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => PayDuesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        user_year_group != null &&
                                                user_year_group!.length >= 2
                                            ? "${user_year_group!.substring(user_year_group!.length - 2)} year group"
                                            : "Year group",
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      MembersScreen()));
                                        },
                                        child: Container(
                                          child: Text('View All',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: odaPrimary)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  if (userData.users?.data?.isEmpty ?? true)
                                    Container(
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
                                        children: [
                                          Icon(Icons.people_outline,
                                              size: 60,
                                              color: Color(0xFF64748b)),
                                          SizedBox(height: 16),
                                          Text(
                                            'No members yet',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF94a3b8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: userData.users!.data!.take(6).map((user) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          MemberDetailPage(
                                                              data: user)));
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                              child: Row(
                                                children: [
                                                  if (user.image != null && user.image!.isNotEmpty) ...[
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration:
                                                          BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                user.image!),
                                                            fit:
                                                                BoxFit.cover),
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration:
                                                          BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        color:
                                                            Color(0xFF334155),
                                                        border: Border.all(
                                                          color: Color(
                                                              0xFF475569),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          ((user.firstName?.isNotEmpty ?? false)
                                                                  ? user.firstName!.substring(0, 1)
                                                                  : '') +
                                                              ((user.lastName?.isNotEmpty ?? false)
                                                                  ? user.lastName!.substring(0, 1)
                                                                  : ''),
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: Colors.white),
                                                        ),
                                                        if (user.email != null && user.email!.isNotEmpty) ...[
                                                          SizedBox(height: 4),
                                                          Text(
                                                            user.email!,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(0xFF94a3b8)),
                                                            maxLines: 1,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: Color(0xFF64748b),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Latest Events",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      EventsScreen()));
                                        },
                                        child: Text('View All',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: odaPrimary)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  if (eventsData.events?.data?.isEmpty ?? true)
                                    Container(
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
                                        children: [
                                          Icon(Icons.event_busy,
                                              size: 60,
                                              color: Color(0xFF64748b)),
                                          SizedBox(height: 16),
                                          Text(
                                            'No upcoming events',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF94a3b8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: eventsData.events!.data!.take(3).map((event) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          EventDetailsScreen(
                                                              data: event)));
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
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
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF334155),
                                                      borderRadius:
                                                          BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: Color(0xFF475569),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: _buildEventDate(event.startDate),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          event.title ?? 'Untitled Event',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight.w600,
                                                              color: Colors.white),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: Color(0xFF64748b),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Projects",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (BuildContext
                                                          context) =>
                                                      ProjectsScreen()));
                                        },
                                        child: Text('View All',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: odaPrimary)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  if (projectsData.projects?.data?.isEmpty ?? true)
                                    Container(
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
                                        children: [
                                          Icon(Icons.work_off,
                                              size: 60,
                                              color: Color(0xFF64748b)),
                                          SizedBox(height: 16),
                                          Text(
                                            'No active projects',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Color(0xFF94a3b8),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: projectsData.projects!.data!.take(3).map((project) {
                                        final currentFunding = double.tryParse(project.currentFunding ?? '0') ?? 0;
                                        final targetFunding = double.tryParse(project.fundingTarget ?? '1') ?? 1;
                                        final fundingProgress = targetFunding > 0 ? (currentFunding / targetFunding).clamp(0.0, 1.0) : 0.0;
                                        final fundingPercentage = (fundingProgress * 100).toInt();

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext context) =>
                                                          ProjectDetailsScreen(data: project)));
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
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(10),
                                                          color: (project.image?.isNotEmpty ?? false)
                                                              ? null
                                                              : Color(0xFF334155),
                                                          border: Border.all(
                                                            color: Color(0xFF475569),
                                                            width: 1,
                                                          ),
                                                          image: (project.image?.isNotEmpty ?? false)
                                                              ? DecorationImage(
                                                                  image: NetworkImage(project.image!),
                                                                  fit: BoxFit.cover)
                                                              : null,
                                                        ),
                                                        child: (project.image?.isNotEmpty ?? false)
                                                            ? null
                                                            : Center(
                                                                child: Icon(
                                                                  Icons.card_giftcard_outlined,
                                                                  size: 30,
                                                                  color: Color(0xFF64748b),
                                                                ),
                                                              ),
                                                      ),
                                                      SizedBox(width: 15),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              project.title ?? 'Untitled Project',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: Colors.white),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            if (project.content != null && project.content!.isNotEmpty) ...[
                                                              SizedBox(height: 4),
                                                              Text(
                                                                project.content!,
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF94a3b8)),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 16,
                                                        color: Color(0xFF64748b),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Funding Progress',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(0xFF94a3b8),
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '$fundingPercentage%',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: odaPrimary,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  ClipRRect(
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: LinearProgressIndicator(
                                                      value: fundingProgress,
                                                      backgroundColor: Color(0xFF334155),
                                                      valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
                                                      minHeight: 8,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 30),
                            if (articlesData != null &&
                                articlesData.news != null &&
                                articlesData.news!.data != null &&
                                articlesData.news!.data!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Latest Discussions",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        AllNewsScreen()));
                                          },
                                          child: Text('View All',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight:
                                                      FontWeight.w600,
                                                  color: odaPrimary)),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    Column(
                                      children: articlesData.news!.data!.take(3).map((article) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext context) =>
                                                          NewsDetailsScreen(data: article)));
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
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      color: Color(0xFF334155),
                                                      border: Border.all(
                                                        color: Color(0xFF475569),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.article_outlined,
                                                        size: 30,
                                                        color: odaPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          article.title ?? 'Untitled Discussion',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w600,
                                                              color: Colors.white),
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                        if (article.createdTime != null && article.createdTime!.isNotEmpty) ...[
                                                          SizedBox(height: 4),
                                                          Text(
                                                            convertToFormattedDate(article.createdTime!),
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(0xFF94a3b8)),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: Color(0xFF64748b),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 80)
                          ],
                        ),
                      ),
                      FooterNav(activeTab: 'home'),
                    ],
                  ),
                ),
              );
            } else {
              return Center(
                child: Text('No data available'),
              );
            }
          },
        ),
      ),
    );
  }
}
