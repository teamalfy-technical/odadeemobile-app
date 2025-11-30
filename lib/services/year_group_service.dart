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
        
        final totalDues = (yearGroup['totalDues'] ?? 0).toDouble();
        final membershipFees = (yearGroup['totalMembershipFees'] ?? yearGroup['membershipFees'] ?? 0).toDouble();
        final collections = (yearGroup['totalCollections'] ?? yearGroup['collections'] ?? 0).toDouble();
        
        if (totalDues > 0 || membershipFees > 0 || collections > 0) {
          return totalDues + membershipFees + collections;
        }
        
        return (yearGroup['totalAmount'] ?? yearGroup['totalContributions'] ?? 0).toDouble();
      }
      return 0.0;
    } catch (e) {
      return 0.0;
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
