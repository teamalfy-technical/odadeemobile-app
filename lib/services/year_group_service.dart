import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/models/event.dart';
import 'package:odadee/utils/image_url_helper.dart';

class YearGroupService {
  static final YearGroupService _instance = YearGroupService._internal();
  factory YearGroupService() => _instance;
  YearGroupService._internal();

  final AuthService _authService = AuthService();
  
  // Cache for year groups to avoid redundant API calls
  static List<YearGroup>? _cachedYearGroups;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 10);
  
  // Cache for user's year group
  static YearGroup? _cachedUserYearGroup;
  static String? _cachedUserYearGroupId;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Future<List<YearGroup>> getAllYearGroups({bool forceRefresh = false}) async {
    // Return cached data if available and not expired
    if (!forceRefresh && _cachedYearGroups != null && _cacheTime != null) {
      if (DateTime.now().difference(_cacheTime!) < _cacheDuration) {
        return _cachedYearGroups!;
      }
    }
    
    try {
      final response = await _authService.authenticatedRequest(
        'GET',
        '/api/year-groups',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> groupsJson = data['yearGroups'] ?? [];
        final groups = groupsJson.map((g) => YearGroup.fromJson(g)).toList();
        
        // Cache the result
        _cachedYearGroups = groups;
        _cacheTime = DateTime.now();
        
        return groups;
      }
      throw Exception('Failed to load year groups');
    } catch (e) {
      rethrow;
    }
  }
  
  /// Fast method to get user's year group ID
  /// Returns cached ID if available, otherwise falls back to getUserYearGroup()
  Future<String?> getUserYearGroupIdFast() async {
    // Return cached ID if available (this is the real year group ID, not graduation year)
    if (_cachedUserYearGroupId != null) {
      return _cachedUserYearGroupId;
    }
    
    // If no cached ID, call getUserYearGroup which will populate the cache
    final yearGroup = await getUserYearGroup();
    return yearGroup?.id;
  }

  /// Fetches year groups for registration/sign-up flows
  /// Always returns fallback list since public API endpoint is not available
  Future<List<YearGroup>> getPublicYearGroups() async {
    // Public year groups endpoint is not available, use fallback directly
    return _generateFallbackYearGroups();
  }

  /// Generate a list of year groups from 1960 to current year
  /// Used as fallback when the public API endpoint is unavailable
  List<YearGroup> _generateFallbackYearGroups() {
    final currentYear = DateTime.now().year;
    final List<YearGroup> groups = [];
    for (int year = currentYear; year >= 1960; year--) {
      groups.add(YearGroup(
        id: year.toString(),
        year: year,
        name: 'Class of $year',
        description: 'PRESEC graduating class of $year',
        memberCount: 0,
        createdAt: DateTime.now(),
      ));
    }
    return groups;
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
    // Return cached user year group if available
    if (_cachedUserYearGroup != null) {
      return _cachedUserYearGroup;
    }
    
    try {
      Map<String, dynamic>? userData = await _authService.getCachedUser();
      userData ??= await _authService.getCurrentUser();

      final graduationYearRaw = userData['graduationYear'] ??
          userData['yearGroup'] ??
          userData['year_group'];

      if (graduationYearRaw == null) return null;

      final int? graduationYear = graduationYearRaw is int
          ? graduationYearRaw
          : int.tryParse(graduationYearRaw.toString());

      if (graduationYear == null) return null;

      final yearGroups = await getAllYearGroups();

      final matchingGroup = yearGroups.firstWhere(
        (g) => g.year == graduationYear,
        orElse: () =>
            throw Exception('Year group not found for year $graduationYear'),
      );
      
      // Cache the result including the real year group ID
      _cachedUserYearGroup = matchingGroup;
      _cachedUserYearGroupId = matchingGroup.id;

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
        return duesCollection.totalCollectedAmount +
            duesCollection.totalPendingAmount;
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
        final membershipFees = _parseDouble(
            yearGroup['totalMembershipFees'] ?? yearGroup['membershipFees']);
        final collections = _parseDouble(
            yearGroup['totalCollections'] ?? yearGroup['collections']);

        if (totalDues > 0 || membershipFees > 0 || collections > 0) {
          return totalDues + membershipFees + collections;
        }

        return _parseDouble(
            yearGroup['totalAmount'] ?? yearGroup['totalContributions']);
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  Future<DuesCollectionSummary?> getDuesCollectionSummary(
      String yearGroupId) async {
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
      totalContributions:
          (json['totalContributions'] ?? json['total_contributions'] ?? 0)
              .toDouble(),
      totalDues: (json['totalDues'] ?? json['total_dues'] ?? 0).toDouble(),
      totalMembershipFees:
          (json['totalMembershipFees'] ?? json['membership_fees'] ?? 0)
              .toDouble(),
      totalCollections:
          (json['totalCollections'] ?? json['collections'] ?? 0).toDouble(),
      membersCount: json['membersCount'] ?? json['members_count'] ?? 0,
      projectsCount: json['projectsCount'] ?? json['projects_count'] ?? 0,
    );
  }

  double get totalAmount =>
      totalContributions + totalDues + totalMembershipFees + totalCollections;
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

  String get formattedTotalCollected =>
      '$currency ${totalCollectedAmount.toStringAsFixed(2)}';
  String get formattedTotalPending =>
      '$currency ${totalPendingAmount.toStringAsFixed(2)}';
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
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  String get fullName => '$firstName $lastName';
  bool get isSuccessful =>
      status.toLowerCase() == 'successful' ||
      status.toLowerCase() == 'completed';
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
    final yearRaw = json['year'];
    final int year =
        yearRaw is int ? yearRaw : int.tryParse(yearRaw?.toString() ?? '') ?? 0;

    return YearGroup(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Class of $year',
      year: year,
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
      skills: json['skills'] != null ? List<String>.from(json['skills']) : null,
    );
  }

  String get fullName => '$firstName $lastName';
}
