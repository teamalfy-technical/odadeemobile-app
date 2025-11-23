import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odadee/Screens/Events/event_details.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Projects/project_details.dart';
import 'package:odadee/Screens/Radio/playing_screen.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/event_service.dart';
import 'package:odadee/models/event.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import 'package:http/http.dart' as http;



class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Event> eventsList = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchEventsData();
  }

  Future<void> _fetchEventsData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final eventService = EventService();
      final events = await eventService.getPublicEvents();

      setState(() {
        eventsList = events;
        isLoading = false;
      });
      print('Events loaded successfully: ${events.length} items');
    } catch (e) {
      print('Error fetching events: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load events. Please try again.';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events. Please try again.'),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _fetchEventsData(),
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
                itemCount: eventsList.length,
                padding: EdgeInsets.all(15),
                itemBuilder: (context, index) {
                  final eventItem = eventsList[index];
                  final dateInfo = _extractDateInfo(eventItem.startDate);
                  
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
                                    dateInfo['day'].toString(),
                                    style: TextStyle(
                                        fontSize: 32,
                                        color: Color(0xFF2563eb),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    dateInfo['month'].toString(),
                                    style: TextStyle(
                                        fontSize: 12, color: Color(0xFF94a3b8)),
                                  ),
                                  Text(
                                    dateInfo['year'].toString(),
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
                                    eventItem.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    eventItem.description,
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

  Map<String, dynamic> _extractDateInfo(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return {
      'day': date.day.toString().padLeft(2, '0'),
      'month': months[date.month - 1],
      'year': date.year.toString(),
    };
  }
}
