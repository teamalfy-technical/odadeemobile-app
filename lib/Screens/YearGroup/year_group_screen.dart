import 'package:flutter/material.dart';
import 'package:odadee/services/year_group_service.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/components/authenticated_image.dart';
import 'package:odadee/utils/image_url_helper.dart';
import 'package:odadee/Screens/Projects/project_details.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/theme_service.dart';
import 'package:intl/intl.dart';

class YearGroupScreen extends StatefulWidget {
  final String? yearGroupId;
  
  const YearGroupScreen({Key? key, this.yearGroupId}) : super(key: key);

  @override
  State<YearGroupScreen> createState() => _YearGroupScreenState();
}

class _YearGroupScreenState extends State<YearGroupScreen> with SingleTickerProviderStateMixin {
  final YearGroupService _yearGroupService = YearGroupService();
  late TabController _tabController;
  
  YearGroup? _yearGroup;
  List<YearGroupMember> _members = [];
  List<Project> _projects = [];
  
  bool _isLoading = true;
  bool _loadingMembers = true;
  bool _loadingProjects = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadYearGroup();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadYearGroup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      YearGroup? yearGroup;
      
      if (widget.yearGroupId != null) {
        yearGroup = await _yearGroupService.getYearGroupDetails(widget.yearGroupId!);
      } else {
        yearGroup = await _yearGroupService.getUserYearGroup();
      }
      
      if (yearGroup == null) {
        setState(() {
          _isLoading = false;
          _error = 'No year group found. Please update your graduation year in your profile.';
        });
        return;
      }
      
      setState(() {
        _yearGroup = yearGroup;
        _isLoading = false;
      });
      
      _loadMembers();
      _loadProjects();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load year group: ${e.toString()}';
      });
    }
  }

  Future<void> _loadMembers() async {
    if (_yearGroup == null) return;
    
    setState(() => _loadingMembers = true);
    try {
      final members = await _yearGroupService.getYearGroupMembers(_yearGroup!.id);
      setState(() {
        _members = members;
        _loadingMembers = false;
      });
    } catch (e) {
      setState(() => _loadingMembers = false);
    }
  }

  Future<void> _loadProjects() async {
    if (_yearGroup == null) return;
    
    setState(() => _loadingProjects = true);
    try {
      final projects = await _yearGroupService.getYearGroupProjects(_yearGroup!.id);
      setState(() {
        _projects = projects;
        _loadingProjects = false;
      });
    } catch (e) {
      setState(() => _loadingProjects = false);
    }
  }

  Widget _buildOverviewTab() {
    if (_yearGroup == null) return SizedBox();
    
    final cardColor = AppColors.cardColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    final borderColor = AppColors.borderColor(context);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [odaPrimary, Color(0xFF1e40af)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${_yearGroup!.year}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  _yearGroup!.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_yearGroup!.description != null) ...[
                  SizedBox(height: 8),
                  Text(
                    _yearGroup!.description!,
                    style: TextStyle(
                      color: Colors.white.withAlpha(204),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  value: _loadingMembers ? '...' : '${_members.length}',
                  label: 'Members',
                  color: odaPrimary,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.work,
                  value: _loadingProjects ? '...' : '${_projects.length}',
                  label: 'Projects',
                  color: odaSecondary,
                  cardColor: cardColor,
                  textColor: textColor,
                  subtitleColor: subtitleColor,
                  borderColor: borderColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 24),
          
          Text(
            'Quick Actions',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          
          _buildQuickActionCard(
            icon: Icons.people_outline,
            title: 'View Members',
            subtitle: 'See all classmates in your year',
            onTap: () => _tabController.animateTo(1),
            cardColor: cardColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            mutedColor: mutedColor,
            borderColor: borderColor,
          ),
          SizedBox(height: 12),
          _buildQuickActionCard(
            icon: Icons.work_outline,
            title: 'Class Projects',
            subtitle: 'Support and contribute to year group initiatives',
            onTap: () => _tabController.animateTo(2),
            cardColor: cardColor,
            textColor: textColor,
            subtitleColor: subtitleColor,
            mutedColor: mutedColor,
            borderColor: borderColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color borderColor,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
    required Color subtitleColor,
    required Color mutedColor,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: odaPrimary.withAlpha(51),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: odaPrimary, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: mutedColor),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersTab() {
    final cardColor = AppColors.cardColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    final borderColor = AppColors.borderColor(context);
    
    if (_loadingMembers) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
        ),
      );
    }
    
    if (_members.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: mutedColor),
            SizedBox(height: 16),
            Text(
              'No members yet',
              style: TextStyle(color: textColor, fontSize: 18),
            ),
            Text(
              'Be the first to join!',
              style: TextStyle(color: subtitleColor),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadMembers,
      color: odaPrimary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _members.length,
        itemBuilder: (context, index) {
          final member = _members[index];
          return _buildMemberCard(member, cardColor, textColor, subtitleColor, mutedColor, borderColor);
        },
      ),
    );
  }

  Widget _buildMemberCard(YearGroupMember member, Color cardColor, Color textColor, Color subtitleColor, Color mutedColor, Color borderColor) {
    final user = member.user;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildAvatar(user?.profileImage, user?.fullName ?? 'Member', 50),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user?.fullName ?? 'Anonymous',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (member.isAdmin)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: odaSecondary.withAlpha(51),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Admin',
                          style: TextStyle(
                            color: odaSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                if (user?.profession != null) ...[
                  SizedBox(height: 4),
                  Text(
                    user!.profession!,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (user?.location != null) ...[
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: mutedColor),
                      SizedBox(width: 4),
                      Text(
                        user!.location!,
                        style: TextStyle(
                          color: mutedColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsTab() {
    final cardColor = AppColors.cardColor(context);
    final surfaceColor = AppColors.surfaceColor(context);
    final textColor = AppColors.textColor(context);
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    final borderColor = AppColors.borderColor(context);
    
    if (_loadingProjects) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
        ),
      );
    }
    
    if (_projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 64, color: mutedColor),
            SizedBox(height: 16),
            Text(
              'No projects yet',
              style: TextStyle(color: textColor, fontSize: 18),
            ),
            Text(
              'Year group projects will appear here',
              style: TextStyle(color: subtitleColor),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadProjects,
      color: odaPrimary,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _projects.length,
        itemBuilder: (context, index) {
          final project = _projects[index];
          return _buildProjectCard(project, cardColor, surfaceColor, textColor, subtitleColor, mutedColor, borderColor);
        },
      ),
    );
  }

  Widget _buildProjectCard(Project project, Color cardColor, Color surfaceColor, Color textColor, Color subtitleColor, Color mutedColor, Color borderColor) {
    final progress = project.targetAmount != null && project.targetAmount! > 0
        ? (project.currentAmount ?? 0) / project.targetAmount!
        : 0.0;
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailsScreen(data: project),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                child: Image.network(
                  project.imageUrl!,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      color: surfaceColor,
                      child: Center(
                        child: Icon(Icons.work, color: mutedColor, size: 40),
                      ),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (project.category.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: odaPrimary.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            project.category,
                            style: TextStyle(
                              color: odaPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      Spacer(),
                      if (project.status.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: project.status == 'active'
                                ? Color(0xFF10b981).withAlpha(51)
                                : mutedColor.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            project.status.toUpperCase(),
                            style: TextStyle(
                              color: project.status == 'active'
                                  ? Color(0xFF10b981)
                                  : subtitleColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    project.title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: borderColor,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 1.0 ? Color(0xFF10b981) : odaPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'GH₵ ${NumberFormat('#,##0.00').format(project.currentAmount ?? 0)}',
                        style: TextStyle(
                          color: odaPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'of GH₵ ${NumberFormat('#,##0.00').format(project.targetAmount ?? 0)}',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? imageUrl, String name, double size) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final normalizedUrl = ImageUrlHelper.normalizeImageUrl(imageUrl);
      if (normalizedUrl != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: AuthenticatedImage(
            imageUrl: normalizedUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: _buildInitialsAvatar(name, size),
            errorWidget: _buildInitialsAvatar(name, size),
          ),
        );
      }
    }
    return _buildInitialsAvatar(name, size);
  }

  Widget _buildInitialsAvatar(String name, double size) {
    final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: odaPrimary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;
    final subtitleColor = AppColors.subtitleColor(context);
    final mutedColor = AppColors.mutedColor(context);
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _yearGroup?.name ?? 'Year Group',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: _yearGroup != null ? TabBar(
          controller: _tabController,
          labelColor: odaPrimary,
          unselectedLabelColor: mutedColor,
          indicatorColor: odaPrimary,
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Members'),
            Tab(text: 'Projects'),
          ],
        ) : null,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(odaPrimary),
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: mutedColor),
                        SizedBox(height: 16),
                        Text(
                          _error!,
                          style: TextStyle(color: subtitleColor, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadYearGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: odaPrimary,
                          ),
                          child: Text('Retry', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildMembersTab(),
                    _buildProjectsTab(),
                  ],
                ),
    );
  }
}
