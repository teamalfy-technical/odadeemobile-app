import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/AllUsers/models/all_users_model.dart'
    as users_model;
import 'package:odadee/Screens/AllUsers/member_detail_page.dart';
import 'package:odadee/Screens/Members/members_screen.dart';
import 'package:odadee/Screens/Articles/models/all_articles_model.dart'
    as articles_model;
import 'package:odadee/Screens/Events/event_details.dart';
import 'package:odadee/Screens/Events/events_list.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Projects/project_details.dart';
import 'package:odadee/Screens/Projects/projects_screen.dart';
import 'package:odadee/Screens/Discussions/discussions_screen.dart';
import 'package:odadee/Screens/YearGroup/year_group_screen.dart';
import 'package:odadee/components/stat_card.dart';
import 'package:odadee/components/footer_nav.dart';
import 'package:odadee/components/event_image_widget.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/services/theme_service.dart';
import 'package:odadee/services/event_service.dart';
import 'package:odadee/services/project_service.dart';
import 'package:odadee/models/event.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/services/year_group_service.dart';

import '../Authentication/SignIn/sgin_in_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<users_model.AllUsersModel> _fetchAllUsersData() async {
    try {
      final authService = AuthService();
      final response =
          await authService.authenticatedRequest('GET', '/api/users');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return users_model.AllUsersModel.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const SignInScreen()));
        }
        throw Exception('Session expired. Please sign in again.');
      } else {
        throw Exception('Failed to load users. Status: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on http.ClientException catch (_) {
      throw Exception(
          'Network error: Unable to connect to server. Please check your internet connection.');
    } on HttpException catch (_) {
      throw Exception('Network error: Unable to connect to server.');
    } on FormatException catch (_) {
      throw Exception('Invalid data received from server.');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Event>> _fetchAllEventsData() async {
    try {
      final eventService = EventService();
      final events = await eventService.getPublicEvents();
      events.sort((a, b) => b.startDate.compareTo(a.startDate));
      return events;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Project>> _fetchAllProjectsData() async {
    try {
      final projectService = ProjectService();
      final projects = await projectService.getPublicProjects();
      return projects;
    } catch (e) {
      rethrow;
    }
  }

  Future<articles_model.AllArticlesModel?> _fetchAllArticlesData() async {
    try {
      final authService = AuthService();
      final response =
          await authService.authenticatedRequest('GET', '/api/discussions');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['discussions'] != null) {
          final discussionsList = jsonData['discussions'] as List;

          // Sort discussions by createdAt date (newest first)
          discussionsList.sort((a, b) {
            final dateA =
                DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime(1970);
            final dateB =
                DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime(1970);
            return dateB.compareTo(dateA);
          });

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

          return articles_model.AllArticlesModel.fromJson(articlesJson);
        }
        return null;
      } else if (response.statusCode == 401) {
        if (mounted) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) => const SignInScreen()));
        }
        return null;
      } else {
        return null;
      }
    } catch (e) {
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
      return null;
    }
  }

  Future<List<YearGroupMember>> _fetchYearGroupMembers() async {
    try {
      final yearGroupService = YearGroupService();
      // Use cached getUserYearGroup which now has caching to avoid redundant calls
      final yearGroup = await yearGroupService.getUserYearGroup();
      if (yearGroup == null) {
        return [];
      }
      final members = await yearGroupService.getYearGroupMembers(yearGroup.id);
      return members;
    } catch (e) {
      return [];
    }
  }

  Future<double> _fetchYearGroupContributions() async {
    try {
      final yearGroupService = YearGroupService();
      // Use cached getUserYearGroup which now has caching to avoid redundant calls
      final yearGroup = await yearGroupService.getUserYearGroup();
      if (yearGroup == null) {
        return 0.0;
      }
      final contributions =
          await yearGroupService.getYearGroupContributions(yearGroup.id);
      return contributions;
    } catch (e) {
      return 0.0;
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
      final userData = await authService.getCurrentUser();

      if (userData == null) {
        return;
      }

      if (mounted) {
        setState(() {
          final firstName = userData['firstName']?.toString() ??
              userData['first_name']?.toString() ??
              '';
          userName = firstName.isNotEmpty ? firstName : null;
          userEmail = userData['email']?.toString() ?? '';

          final yearGroup = userData['yearGroup']?.toString() ??
              userData['year_group']?.toString() ??
              userData['graduationYear']?.toString() ??
              '';
          userClass = yearGroup.isNotEmpty ? 'Class of $yearGroup' : '';
        });
      }
    } catch (e) {
      // Non-critical error, continue without user data
    }
  }

  Widget _buildEventDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date == null) {
        return _buildDateFallback();
      } else if (date is String) {
        if (date.isEmpty) return _buildDateFallback();
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return _buildDateFallback();
      }

      final dateInfo = _extractDateInfoFromDateTime(dateTime);
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

  Map<String, dynamic> _extractDateInfoFromDateTime(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return {
      'day': date.day.toString().padLeft(2, '0'),
      'month': months[date.month - 1],
      'year': date.year.toString(),
    };
  }

  String _formatEventDate(dynamic date) {
    try {
      DateTime dateTime;
      if (date == null) {
        return 'Date TBA';
      } else if (date is String) {
        if (date.isEmpty) return 'Date TBA';
        dateTime = DateTime.parse(date);
      } else if (date is DateTime) {
        dateTime = date;
      } else {
        return 'Date TBA';
      }

      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    } catch (e) {
      return 'Date TBA';
    }
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
            _fetchYearGroupMembers(),
            _fetchYearGroupContributions(),
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
              final userData = snapshot.data![0] as users_model.AllUsersModel;

              final eventsData = snapshot.data![1] as List<Event>;

              final projectsData = snapshot.data![2] as List<Project>;

              final articlesData =
                  snapshot.data![3] as articles_model.AllArticlesModel?;

              final yearGroupMembers =
                  snapshot.data![5] as List<YearGroupMember>;

              final yearGroupContributions = snapshot.data![6] as double;

              // Check if critical data is null (users, events, projects are required)
              // Data is guaranteed to be present if we get here

              final int usersCount = userData.users?.data?.length ?? 0;
              final int eventsCount = eventsData.length;
              final int projectsCount = projectsData.length;
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 50,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.asset(
                                                  'assets/images/presec_logo.webp',
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    userName != null &&
                                                            userName!.isNotEmpty
                                                        ? "Welcome back, $userName!"
                                                        : "Welcome back!",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 20,
                                                      color:
                                                          AppColors.textColor(
                                                              context),
                                                    ),
                                                  ),
                                                  if (userEmail != null &&
                                                      userEmail!
                                                          .isNotEmpty) ...[
                                                    SizedBox(height: 2),
                                                    Text(
                                                      userEmail!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .subtitleColor(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                  if (userClass != null &&
                                                      userClass!
                                                          .isNotEmpty) ...[
                                                    SizedBox(height: 2),
                                                    Text(
                                                      userClass!,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors
                                                            .subtitleColor(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w400,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                                                  builder:
                                                      (BuildContext context) =>
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
                                  if (eventsData.isEmpty)
                                    Container(
                                      padding: EdgeInsets.all(40),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.event_busy,
                                              size: 60,
                                              color: AppColors.mutedColor(
                                                  context)),
                                          SizedBox(height: 16),
                                          Text(
                                            'No upcoming events',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.subtitleColor(
                                                  context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: eventsData.take(3).map((event) {
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
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  EventImageWidget(
                                                    imageUrl: event.bannerUrl,
                                                    height: 60,
                                                    width: 60,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          event.title ??
                                                              'Untitled Event',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .textColor(
                                                                      context)),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        if (event.startDate !=
                                                            null) ...[
                                                          SizedBox(height: 4),
                                                          Text(
                                                            _formatEventDate(
                                                                event
                                                                    .startDate!),
                                                            style: TextStyle(
                                                              fontSize: 13,
                                                              color: AppColors
                                                                  .subtitleColor(
                                                                      context),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                  ),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 16,
                                                    color: AppColors.mutedColor(
                                                        context),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                                                  builder:
                                                      (BuildContext context) =>
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
                                  if (projectsData.isEmpty)
                                    Container(
                                      padding: EdgeInsets.all(40),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.work_off,
                                              size: 60,
                                              color: AppColors.mutedColor(
                                                  context)),
                                          SizedBox(height: 16),
                                          Text(
                                            'No active projects',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.subtitleColor(
                                                  context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children:
                                          projectsData.take(3).map((project) {
                                        final fundingProgress =
                                            project.fundingProgress;
                                        final fundingPercentage =
                                            project.fundingPercentage;

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          ProjectDetailsScreen(
                                                              data: project)));
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 60,
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: (project
                                                                      .imageUrl
                                                                      ?.isNotEmpty ??
                                                                  false)
                                                              ? null
                                                              : Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .surfaceContainer,
                                                          border: Border.all(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .outline,
                                                            width: 1,
                                                          ),
                                                          image: (project
                                                                      .imageUrl
                                                                      ?.isNotEmpty ??
                                                                  false)
                                                              ? DecorationImage(
                                                                  image: NetworkImage(
                                                                      project
                                                                          .imageUrl!),
                                                                  fit: BoxFit
                                                                      .cover)
                                                              : null,
                                                        ),
                                                      ),
                                                      SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              project.title,
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: AppColors
                                                                      .textColor(
                                                                          context)),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                            if (project
                                                                .description
                                                                .isNotEmpty) ...[
                                                              SizedBox(
                                                                  height: 4),
                                                              Text(
                                                                project
                                                                    .description,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: AppColors
                                                                        .subtitleColor(
                                                                            context)),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ],
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        size: 16,
                                                        color: AppColors
                                                            .mutedColor(
                                                                context),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                        'Funding Progress',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .subtitleColor(
                                                                  context),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                      Text(
                                                        '$fundingPercentage%',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: odaPrimary,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: fundingProgress,
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .surfaceContainer,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              odaPrimary),
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
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                                          builder: (context) => MembersScreen(),
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
                                    title: 'Year Group Dues',
                                    value:
                                        'GH¢ ${yearGroupContributions.toStringAsFixed(2)}',
                                    icon: Icons.payments,
                                    subtitle: 'Dues & contributions',
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
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
                                                  builder:
                                                      (BuildContext context) =>
                                                          YearGroupScreen()));
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
                                  if (yearGroupMembers.isEmpty)
                                    Container(
                                      padding: EdgeInsets.all(40),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(Icons.people_outline,
                                              size: 60,
                                              color: AppColors.mutedColor(
                                                  context)),
                                          SizedBox(height: 16),
                                          Text(
                                            'No classmates found',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.subtitleColor(
                                                  context),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Update your graduation year in your profile',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  AppColors.mutedColor(context),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Column(
                                      children: yearGroupMembers
                                          .take(6)
                                          .map((member) {
                                        final user = member.user;
                                        final firstName = user?.firstName ?? '';
                                        final lastName = user?.lastName ?? '';
                                        final fullName =
                                            '$firstName $lastName'.trim();
                                        final email = user?.email ?? '';
                                        final profileImage = user?.profileImage;

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              final memberData = users_model
                                                      .Data
                                                  .fromYearGroupMember(member);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          MemberDetailPage(
                                                              data:
                                                                  memberData)));
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  if (profileImage != null &&
                                                      profileImage
                                                          .isNotEmpty) ...[
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                                profileImage),
                                                            fit: BoxFit.cover),
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    Container(
                                                      height: 60,
                                                      width: 60,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainer,
                                                        border: Border.all(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .outline,
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          (firstName.isNotEmpty
                                                                  ? firstName
                                                                      .substring(
                                                                          0, 1)
                                                                  : '') +
                                                              (lastName
                                                                      .isNotEmpty
                                                                  ? lastName
                                                                      .substring(
                                                                          0, 1)
                                                                  : ''),
                                                          style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .textColor(
                                                                      context)),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          fullName.isNotEmpty
                                                              ? fullName
                                                              : 'Anonymous',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .textColor(
                                                                      context)),
                                                        ),
                                                        if (email
                                                            .isNotEmpty) ...[
                                                          SizedBox(height: 4),
                                                          Text(
                                                            email,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: AppColors
                                                                    .subtitleColor(
                                                                        context)),
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
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
                            if (articlesData != null &&
                                articlesData.news != null &&
                                articlesData.news!.data != null &&
                                articlesData.news!.data!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
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
                                              color:
                                                  AppColors.textColor(context)),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        DiscussionsScreen()));
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
                                    Column(
                                      children: articlesData.news!.data!
                                          .take(3)
                                          .map((article) {
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 15),
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (BuildContext
                                                              context) =>
                                                          DiscussionsScreen()));
                                            },
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    height: 60,
                                                    width: 60,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .surfaceContainer,
                                                      border: Border.all(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .outline,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: Icon(
                                                        Icons.forum_outlined,
                                                        size: 30,
                                                        color: odaPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 15),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          article.title ??
                                                              'Untitled Discussion',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: AppColors
                                                                  .textColor(
                                                                      context)),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        if (article.createdTime !=
                                                                null &&
                                                            article.createdTime!
                                                                .isNotEmpty) ...[
                                                          SizedBox(height: 4),
                                                          Text(
                                                            convertToFormattedDate(
                                                                article
                                                                    .createdTime!),
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: AppColors
                                                                    .subtitleColor(
                                                                        context)),
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
