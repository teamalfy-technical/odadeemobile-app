import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odadee/Screens/Events/event_details.dart';
import 'package:odadee/Screens/Events/models/events_model.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/models/all_projects_model.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Projects/project_details.dart';
import 'package:odadee/Screens/Radio/playing_screen.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:http/http.dart' as http;



class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List eventsList = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchEventsData(currentPage);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (currentPage < lastPage && !isLoading) {
        currentPage++;
        _fetchEventsData(currentPage);
      }
    }
  }

  Future<void> _fetchEventsData(int page) async {
    setState(() {
      isLoading = true;
    });

    try {
      print('===== FETCHING EVENTS PAGE $page =====');
      final authService = AuthService();
      final response = await authService.authenticatedRequest('GET', '/api/events?page=$page');

      print('Events API Status: ${response.statusCode}');
      print('Events API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final eventData = Events.fromJson(data['events']);

        setState(() {
          lastPage = eventData.lastPage!;
          eventsList.addAll(eventData.data!);
          isLoading = false;
        });
        print('Events loaded successfully: ${eventData.data!.length} items');
      } else {
        throw Exception('Failed to load events. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _fetchEventsData(page),
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
          'Events',
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
        child: eventsList.isEmpty && !isLoading
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
                      Icon(Icons.event_busy, size: 60, color: Color(0xFF64748b)),
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
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: eventsList.length,
                padding: EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  final eventItem = eventsList[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 15),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                EventDetailsScreen(data: eventItem)));
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Color(0xFF334155),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xFFf4d03f),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    extractDateInfo(eventItem.startDate!)['day']
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: Color(0xFF2563eb),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    extractDateInfo(eventItem.startDate!)['month']
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 12, color: Color(0xFF94a3b8)),
                                  ),
                                  Text(
                                    extractDateInfo(eventItem.startDate!)['year']
                                        .toString(),
                                    style: TextStyle(
                                        fontSize: 10, color: Color(0xFF64748b)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eventItem.title ?? 'Untitled Event',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    eventItem.content ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 13, color: Color(0xFF94a3b8)),
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
                },
              ),
      ),
    );
  }
}
