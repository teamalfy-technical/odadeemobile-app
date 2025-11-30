import '../utils/image_url_helper.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String? bannerUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final String location;
  final String type;
  final String? yearGroupId;
  final double? ticketPrice;
  final int? maxAttendees;
  final String status;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    this.bannerUrl,
    required this.startDate,
    this.endDate,
    required this.location,
    required this.type,
    this.yearGroupId,
    this.ticketPrice,
    this.maxAttendees,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String? rawImageUrl = json['bannerUrl'] ??
        json['imageUrl'] ??
        json['image'] ??
        json['banner'];

    String? imageUrl = ImageUrlHelper.normalizeImageUrl(rawImageUrl);

    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Event',
      description: json['description'] ?? '',
      bannerUrl: imageUrl,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      location: json['location'] ?? '',
      type: json['type'] ?? 'global',
      yearGroupId: json['yearGroupId'],
      ticketPrice: json['ticketPrice'] != null
          ? double.tryParse(json['ticketPrice'].toString())
          : null,
      maxAttendees: json['maxAttendees'],
      status: json['status'] ?? 'upcoming',
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'bannerUrl': bannerUrl,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'type': type,
      'yearGroupId': yearGroupId,
      'ticketPrice': ticketPrice?.toString(),
      'maxAttendees': maxAttendees,
      'status': status,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class EventRegistration {
  final String id;
  final String eventId;
  final String userId;
  final int ticketsPurchased;
  final double totalAmount;
  final String paymentStatus;
  final bool checkedIn;
  final DateTime registeredAt;

  EventRegistration({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.ticketsPurchased,
    required this.totalAmount,
    required this.paymentStatus,
    required this.checkedIn,
    required this.registeredAt,
  });

  factory EventRegistration.fromJson(Map<String, dynamic> json) {
    return EventRegistration(
      id: json['id'] ?? '',
      eventId: json['eventId'] ?? '',
      userId: json['userId'] ?? '',
      ticketsPurchased: json['ticketsPurchased'] ?? 0,
      totalAmount: json['totalAmount'] != null
          ? double.tryParse(json['totalAmount'].toString()) ?? 0.0
          : 0.0,
      paymentStatus: json['paymentStatus'] ?? 'pending',
      checkedIn: json['checkedIn'] ?? false,
      registeredAt: json['registeredAt'] != null
          ? DateTime.parse(json['registeredAt'])
          : DateTime.now(),
    );
  }
}
