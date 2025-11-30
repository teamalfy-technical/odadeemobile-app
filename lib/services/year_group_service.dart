import 'dart:convert';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/models/event.dart';
import 'package:odadee/utils/image_url_helper.dart';

class YearGroupService {
  static final YearGroupService _instance = YearGroupService._internal();
  factory YearGroupService() => _instance;
  YearGroupService._internal();

  final AuthService _authService = AuthService();

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<List<YearGroup>> getAllYearGroups() async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> groupsJson = data['yearGroups'] ?? [];
        return groupsJson.map((g) => YearGroup.fromJson(g)).toList();
      }
      throw Exception('Failed to load year groups');
    } catch (e) {
      rethrow;
    }
  }

  Future<YearGroup> getYearGroupDetails(String yearGroupId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups/$yearGroupId',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return YearGroup.fromJson(data['yearGroup']);
      }
      throw Exception('Year group not found');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<YearGroupMember>> getYearGroupMembers(String yearGroupId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups/$yearGroupId/members',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> membersJson = data['members'] ?? [];
        return membersJson.map((m) => YearGroupMember.fromJson(m)).toList();
      }
      throw Exception('Failed to load members');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Project>> getYearGroupProjects(String yearGroupId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups/$yearGroupId/projects',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> projectsJson = data['projects'] ?? [];
        return projectsJson.map((p) => Project.fromJson(p)).toList();
      }
      throw Exception('Failed to load year group projects');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> joinYearGroup(String yearGroupId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'POST',
        '/api/year-groups/$yearGroupId/join',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'membership': data['membership'],
          'message': data['message'] ?? 'Join request sent',
        };
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to join year group',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  Future<YearGroup?> getUserYearGroup() async {
    try {
      Map<String, dynamic>? userData = await _authService.getCachedUser();
      if (userData == null) {
        userData = await _authService.getCurrentUser();
      }
      
      final graduationYear = userData['graduationYear'];
      
      if (graduationYear == null) return null;
      
      final yearGroups = await getAllYearGroups();
      
      final matchingGroup = yearGroups.firstWhere(
        (g) => g.year == graduationYear,
        orElse: () => throw Exception('Year group not found for year $graduationYear'),
      );
      
      return matchingGroup;
    } catch (e) {
      return null;
    }
  }

  Future<YearGroupStats?> getYearGroupStats(String yearGroupId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups/$yearGroupId/stats',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return YearGroupStats.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<double> getYearGroupContributions(String yearGroupId) async {
    try {
      final duesCollection = await getDuesCollectionSummary(yearGroupId);
      if (duesCollection != null) {
        return duesCollection.totalCollectedAmount + duesCollection.totalPendingAmount;
      }
      
      final stats = await getYearGroupStats(yearGroupId);
      if (stats != null) {
        return stats.totalAmount;
      }
      
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups/$yearGroupId',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final yearGroup = data['yearGroup'] ?? data;
        
        final totalDues = _parseDouble(yearGroup['totalDues']);
        final membershipFees = _parseDouble(yearGroup['totalMembershipFees'] ?? yearGroup['membershipFees']);
        final collections = _parseDouble(yearGroup['totalCollections'] ?? yearGroup['collections']);
        
        if (totalDues > 0 || membershipFees > 0 || collections > 0) {
          return totalDues + membershipFees + collections;
        }
        
        return _parseDouble(yearGroup['totalAmount'] ?? yearGroup['totalContributions']);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<DuesCollectionSummary?> getDuesCollectionSummary(String yearGroupId) async {
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups/$yearGroupId/dues-collection',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DuesCollectionSummary.fromJson(data);
      }
      
      if (response.statusCode == 403) {
        return null;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

class YearGroupStats {
  final double totalContributions;
  final double totalDues;
  final double totalMembershipFees;
  final double totalCollections;
  final int membersCount;
  final int projectsCount;

  YearGroupStats({
    required this.totalContributions,
    required this.totalDues,
    required this.totalMembershipFees,
    required this.totalCollections,
    required this.membersCount,
    required this.projectsCount,
  });

  factory YearGroupStats.fromJson(Map<String, dynamic> json) {
    return YearGroupStats(
      totalContributions: (json['totalContributions'] ?? json['total_contributions'] ?? 0).toDouble(),
      totalDues: (json['totalDues'] ?? json['total_dues'] ?? 0).toDouble(),
      totalMembershipFees: (json['totalMembershipFees'] ?? json['membership_fees'] ?? 0).toDouble(),
      totalCollections: (json['totalCollections'] ?? json['collections'] ?? 0).toDouble(),
      membersCount: json['membersCount'] ?? json['members_count'] ?? 0,
      projectsCount: json['projectsCount'] ?? json['projects_count'] ?? 0,
    );
  }

  double get totalAmount => totalContributions + totalDues + totalMembershipFees + totalCollections;
}

class DuesCollectionSummary {
  final String totalCollected;
  final String totalPending;
  final int paymentCount;
  final String currency;
  final List<DuesPayment> payments;

  DuesCollectionSummary({
    required this.totalCollected,
    required this.totalPending,
    required this.paymentCount,
    required this.currency,
    required this.payments,
  });

  factory DuesCollectionSummary.fromJson(Map<String, dynamic> json) {
    final List<dynamic> paymentsJson = json['payments'] ?? [];
    return DuesCollectionSummary(
      totalCollected: json['totalCollected']?.toString() ?? '0',
      totalPending: json['totalPending']?.toString() ?? '0',
      paymentCount: json['paymentCount'] ?? 0,
      currency: json['currency'] ?? 'GHS',
      payments: paymentsJson.map((p) => DuesPayment.fromJson(p)).toList(),
    );
  }

  double get totalCollectedAmount => double.tryParse(totalCollected) ?? 0.0;
  double get totalPendingAmount => double.tryParse(totalPending) ?? 0.0;
  double get totalAmount => totalCollectedAmount + totalPendingAmount;
  
  String get formattedTotalCollected => '$currency ${totalCollectedAmount.toStringAsFixed(2)}';
  String get formattedTotalPending => '$currency ${totalPendingAmount.toStringAsFixed(2)}';
  String get formattedTotal => '$currency ${totalAmount.toStringAsFixed(2)}';
  
  double get collectionRate {
    if (totalAmount == 0) return 0;
    return (totalCollectedAmount / totalAmount) * 100;
  }
}

class DuesPayment {
  final String? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final double amount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DuesPayment({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    required this.amount,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory DuesPayment.fromJson(Map<String, dynamic> json) {
    return DuesPayment(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      amount: YearGroupService._parseDouble(json['amount']),
      status: json['status'] ?? 'pending',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  String get fullName => '$firstName $lastName';
  bool get isSuccessful => status.toLowerCase() == 'successful' || status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
}

class YearGroup {
  final String id;
  final String name;
  final int year;
  final String? description;
  final int memberCount;
  final DateTime createdAt;

  YearGroup({
    required this.id,
    required this.name,
    required this.year,
    this.description,
    required this.memberCount,
    required this.createdAt,
  });

  factory YearGroup.fromJson(Map<String, dynamic> json) {
    return YearGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Class of ${json['year'] ?? 'Unknown'}',
      year: json['year'] ?? 0,
      description: json['description'],
      memberCount: json['memberCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class YearGroupMember {
  final String id;
  final String yearGroupId;
  final bool isAdmin;
  final String verificationStatus;
  final DateTime joinedAt;
  final MemberUser? user;

  YearGroupMember({
    required this.id,
    required this.yearGroupId,
    required this.isAdmin,
    required this.verificationStatus,
    required this.joinedAt,
    this.user,
  });

  factory YearGroupMember.fromJson(Map<String, dynamic> json) {
    return YearGroupMember(
      id: json['id'] ?? '',
      yearGroupId: json['yearGroupId'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      user: json['user'] != null ? MemberUser.fromJson(json['user']) : null,
    );
  }
}

class MemberUser {
  final String? id;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final String? profession;
  final String? location;
  final String? profileImage;
  final List<String>? skills;

  MemberUser({
    this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.profession,
    this.location,
    this.profileImage,
    this.skills,
  });

  factory MemberUser.fromJson(Map<String, dynamic> json) {
    String? rawProfileImage = json['profileImage'];
    String? profileImage = ImageUrlHelper.normalizeImageUrl(rawProfileImage);
    
    return MemberUser(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profession: json['profession'],
      location: json['location'],
      profileImage: profileImage,
      skills: json['skills'] != null
          ? List<String>.from(json['skills'])
          : null,
    );
  }

  String get fullName => '$firstName $lastName';
}
