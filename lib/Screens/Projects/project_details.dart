import 'package:flutter/material.dart';
import 'package:odadee/models/project.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/constants.dart';
import 'package:intl/intl.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final dynamic data;

  const ProjectDetailsScreen({super.key, required this.data});

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  Project? get project => widget.data is Project ? widget.data as Project : null;

  String _formatCurrency(double? amount) {
    final formatter = NumberFormat('#,##0.00');
    return 'GH₵ ${formatter.format(amount ?? 0.0)}';
  }

  double _getFundingProgress() {
    if (project == null || (project!.targetAmount ?? 0) == 0) return 0.0;
    final current = project!.currentAmount ?? 0.0;
    final target = project!.targetAmount ?? 1.0;
    if (target == 0) return 0.0;
    return (current / target).clamp(0.0, 1.0);
  }
  
  String _getProgressPercentage() {
    if (project == null || (project!.targetAmount ?? 0) == 0) return '0.0';
    final current = project!.currentAmount ?? 0.0;
    final target = project!.targetAmount ?? 1.0;
    if (target == 0) return '0.0';
    final percentage = (current / target * 100);
    return percentage.toStringAsFixed(1);
  }
  
  bool _isOverfunded() {
    if (project == null || (project!.targetAmount ?? 0) == 0) return false;
    final current = project!.currentAmount ?? 0.0;
    final target = project!.targetAmount ?? 1.0;
    return current > target;
  }

  @override
  Widget build(BuildContext context) {
    if (project == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Project Details', style: TextStyle(color: Colors.black)),
        ),
        body: Center(child: Text('Project not found')),
      );
    }

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
          'Project Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project!.imageUrl != null && project!.imageUrl!.isNotEmpty)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: Color(0xFF1e293b),
                ),
                child: Image.network(
                  project!.imageUrl!.startsWith('http')
                      ? project!.imageUrl!
                      : '${ApiConfig.baseUrl}/${project!.imageUrl}',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Color(0xFF1e293b),
                      child: Center(
                        child: Icon(
                          Icons.work,
                          size: 80,
                          color: Color(0xFF64748b),
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Color(0xFF1e293b),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563eb)),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: Color(0xFF1e293b),
                child: Center(
                  child: Icon(
                    Icons.work,
                    size: 80,
                    color: Color(0xFF64748b),
                  ),
                ),
              ),
            
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (project!.category.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF2563eb).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Color(0xFF2563eb),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            project!.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2563eb),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Spacer(),
                      if (project!.status.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: project!.status == 'active'
                                ? Color(0xFF10b981).withOpacity(0.2)
                                : Color(0xFF64748b).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            project!.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              color: project!.status == 'active' 
                                  ? Color(0xFF10b981) 
                                  : Color(0xFF94a3b8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 20),
                  
                  Text(
                    project!.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFFf4d03f),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Funding Progress',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final containerWidth = constraints.maxWidth;
                            final currentAmt = project!.currentAmount ?? 0.0;
                            final targetAmt = project!.targetAmount ?? 1.0;
                            final rawRatio = targetAmt > 0 ? currentAmt / targetAmt : 0.0;
                            final overflowRatio = rawRatio > 1.0 ? (rawRatio - 1.0) : 0.0;
                            final overflowWidth = containerWidth * overflowRatio;
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: rawRatio.clamp(0.0, 1.0),
                                    minHeight: 12,
                                    backgroundColor: Color(0xFF334155),
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      rawRatio >= 1.0 ? Color(0xFF10b981) : Color(0xFF2563eb)
                                    ),
                                  ),
                                ),
                                if (rawRatio > 1.0)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(10),
                                            child: Container(
                                              height: 6,
                                              width: overflowWidth,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Color(0xFF10b981),
                                                    Color(0xFFf4d03f),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: 10,
                                            color: Color(0xFFf4d03f),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        
                        SizedBox(height: 16),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Raised',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94a3b8),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(project!.currentAmount),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF2563eb),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Goal',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94a3b8),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  _formatCurrency(project!.targetAmount),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 12),
                        
                        Center(
                          child: Column(
                            children: [
                              Text(
                                '${_getProgressPercentage()}% funded',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFf4d03f),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (_isOverfunded())
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'GOAL EXCEEDED',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF10b981),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  Text(
                    'About this project',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    project!.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF94a3b8),
                      height: 1.5,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Project funding coming soon!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF2563eb),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Contribute to Project',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
