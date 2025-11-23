class Project {
  final String id;
  final String title;
  final String description;
  final String category;
  final double? targetAmount;
  final double? currentAmount;
  final String? imageUrl;
  final String status;
  final String? contributionId;
  final String? yearGroupId;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.targetAmount,
    this.currentAmount,
    this.imageUrl,
    required this.status,
    this.contributionId,
    this.yearGroupId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  double get fundingProgress {
    if (targetAmount == null || targetAmount == 0) return 0.0;
    final current = currentAmount ?? 0.0;
    return (current / targetAmount!).clamp(0.0, 1.0);
  }

  int get fundingPercentage {
    return (fundingProgress * 100).toInt();
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled Project',
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      targetAmount: json['targetAmount'] != null
          ? double.tryParse(json['targetAmount'].toString())
          : null,
      currentAmount: json['currentAmount'] != null
          ? double.tryParse(json['currentAmount'].toString())
          : null,
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'active',
      contributionId: json['contributionId'],
      yearGroupId: json['yearGroupId'],
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
      'category': category,
      'targetAmount': targetAmount?.toString(),
      'currentAmount': currentAmount?.toString(),
      'imageUrl': imageUrl,
      'status': status,
      'contributionId': contributionId,
      'yearGroupId': yearGroupId,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
