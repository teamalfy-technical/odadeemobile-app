import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odadee/config/api_config.dart';
import 'package:odadee/models/event.dart';
import 'package:odadee/services/auth_service.dart';

class EventService {
  final AuthService _authService = AuthService();

  Future<List<Event>> getPublicEvents() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.publicEventsEndpoint}'),
        headers: {'Content-Type': 'application/json'},
      );

      print('===== PUBLIC EVENTS API RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body.substring(0, response.body.length < 500 ? response.body.length : 500)}');
      print('======================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> eventsJson = data['events'] ?? [];
        return eventsJson.map((e) => Event.fromJson(e)).toList();
      }
      throw Exception('Failed to load public events');
    } catch (e) {
      print('Error fetching public events: $e');
      rethrow;
    }
  }

  Future<List<Event>> getAllEvents() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        ApiConfig.eventsEndpoint,
      );

      print('===== AUTHENTICATED EVENTS API RESPONSE =====');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body.substring(0, response.body.length < 500 ? response.body.length : 500)}');
      print('===========================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> eventsJson = data['events'] ?? [];
        return eventsJson.map((e) => Event.fromJson(e)).toList();
      }
      throw Exception('Failed to load events');
    } catch (e) {
      print('Error fetching authenticated events: $e');
      rethrow;
    }
  }

  Future<Event> getEventDetails(String eventId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '${ApiConfig.eventsEndpoint}/$eventId',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Event.fromJson(data['event']);
      }
      throw Exception('Event not found');
    } catch (e) {
      print('Error fetching event details: $e');
      rethrow;
    }
  }

  Future<EventRegistration> registerForEvent({
    required String eventId,
    required int ticketsPurchased,
  }) async {
    try {
      final bodyData = {
        'ticketsPurchased': ticketsPurchased,
      };
      
      final response = await _authService.authenticatedRequest(
        'POST',
        '${ApiConfig.eventsEndpoint}/$eventId/register',
        body: bodyData,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EventRegistration.fromJson(data['registration']);
      }
      throw Exception('Registration failed');
    } catch (e) {
      print('Error registering for event: $e');
      rethrow;
    }
  }

  Future<List<EventRegistration>> getMyRegistrations() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '${ApiConfig.eventsEndpoint}/my-registrations',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> registrationsJson = data['registrations'] ?? [];
        return registrationsJson.map((r) => EventRegistration.fromJson(r)).toList();
      }
      throw Exception('Failed to load registrations');
    } catch (e) {
      print('Error fetching registrations: $e');
      rethrow;
    }
  }
}
