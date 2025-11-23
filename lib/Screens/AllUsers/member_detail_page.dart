import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:odadee/Screens/AllUsers/models/all_users_model.dart';
import 'package:odadee/components/authenticated_image.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/constants.dart';

class MemberDetailPage extends StatefulWidget {
  final Data data;
  const MemberDetailPage({Key? key, required this.data}) : super(key: key);

  @override
  State<MemberDetailPage> createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  bool isInfoTab = true;

  String _safeConvertDate(String? dateString) {
    if (dateString == null || dateString.trim().isEmpty) {
      return '';
    }
    try {
      DateTime? parsedDate;
      
      try {
        parsedDate = DateTime.parse(dateString);
      } catch (e) {
        final formats = [
          DateFormat('EEE, dd MMM yyyy HH:mm:ss'),
          DateFormat('yyyy-MM-dd HH:mm:ss'),
          DateFormat('yyyy-MM-dd'),
          DateFormat('dd/MM/yyyy'),
          DateFormat('MM/dd/yyyy'),
        ];
        
        for (var format in formats) {
          try {
            parsedDate = format.parse(dateString);
            break;
          } catch (_) {}
        }
      }
      
      if (parsedDate == null) {
        return '';
      }
      
      final month = DateFormat.MMM().format(parsedDate);
      final day = DateFormat.d().format(parsedDate);
      final year = DateFormat.y().format(parsedDate);
      return "$month $day, $year";
    } catch (e) {
      print('Error converting date "$dateString": $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final String userName = "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim().isNotEmpty 
        ? "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim()
        : 'Unknown User';

    return Scaffold(
      backgroundColor: odaBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          userName,
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            _buildTabBar(),
            isInfoTab ? _buildInformationTab() : _buildStatusTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final String userName = "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim().isNotEmpty 
        ? "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim()
        : 'Unknown User';

    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: odaSecondary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: widget.data.image != null && widget.data.image!.trim().isNotEmpty
                  ? AuthenticatedImage(
                      imageUrl: widget.data.image!.startsWith('http')
                          ? widget.data.image!
                          : '${ApiConfig.baseUrl}${widget.data.image}',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        width: 120,
                        height: 120,
                        color: odaCardBackground,
                        child: Center(
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: bodyText2,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 120,
                      height: 120,
                      color: odaCardBackground,
                      child: Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: bodyText2,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            userName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: bodyText1,
            ),
          ),
          SizedBox(height: 8),
          if (widget.data.yearGroup != null && widget.data.yearGroup!.trim().isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: odaSecondary, width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "Year Group: ${widget.data.yearGroup}",
                style: TextStyle(
                  fontSize: 14,
                  color: bodyText2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: odaCardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  isInfoTab = true;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isInfoTab ? odaPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Information",
                    style: TextStyle(
                      color: isInfoTab ? Colors.white : bodyText2,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  isInfoTab = false;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isInfoTab ? odaPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Status",
                    style: TextStyle(
                      color: !isInfoTab ? Colors.white : bodyText2,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.data.about != null && widget.data.about!.trim().isNotEmpty)
            _buildInfoCard(
              title: "Bio",
              child: Text(
                widget.data.about!,
                style: TextStyle(
                  fontSize: 15,
                  color: bodyText2,
                  height: 1.5,
                ),
              ),
            ),
          _buildInfoCard(
            title: "Contact Information",
            child: Column(
              children: [
                if (widget.data.email != null && widget.data.email!.trim().isNotEmpty)
                  _buildInfoRow(Icons.email_outlined, "Email", widget.data.email!),
                if (widget.data.phone != null && widget.data.phone!.trim().isNotEmpty)
                  _buildInfoRow(Icons.phone_outlined, "Phone", widget.data.phone!),
                if (widget.data.city != null && widget.data.city!.trim().isNotEmpty)
                  _buildInfoRow(Icons.location_on_outlined, "City", widget.data.city!),
                if (widget.data.country != null && widget.data.country!.trim().isNotEmpty)
                  _buildInfoRow(Icons.public_outlined, "Country", widget.data.country!),
              ],
            ),
          ),
          if (widget.data.workPlace != null && widget.data.workPlace!.trim().isNotEmpty ||
              widget.data.position != null && widget.data.position!.trim().isNotEmpty ||
              widget.data.jobTitle != null && widget.data.jobTitle!.trim().isNotEmpty)
            _buildInfoCard(
              title: "Professional Information",
              child: Column(
                children: [
                  if (widget.data.workPlace != null && widget.data.workPlace!.trim().isNotEmpty)
                    _buildInfoRow(Icons.business_outlined, "Workplace", widget.data.workPlace!),
                  if (widget.data.position != null && widget.data.position!.trim().isNotEmpty)
                    _buildInfoRow(Icons.work_outline, "Position", widget.data.position!),
                  if (widget.data.jobTitle != null && widget.data.jobTitle!.trim().isNotEmpty)
                    _buildInfoRow(Icons.badge_outlined, "Job Title", widget.data.jobTitle!),
                ],
              ),
            ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget child}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: odaCardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: bodyText1,
            ),
          ),
          SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: odaSecondary, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: bodyText2.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: bodyText2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab() {
    final statusList = widget.data.userStatus ?? [];

    if (statusList.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: odaCardBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: bodyText2.withOpacity(0.5),
              ),
              SizedBox(height: 16),
              Text(
                "No status updates yet",
                style: TextStyle(
                  fontSize: 16,
                  color: bodyText2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          for (var status in statusList)
            if (status.status != null && status.status!.trim().isNotEmpty)
              Container(
                margin: EdgeInsets.only(bottom: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: odaCardBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: odaSecondary, width: 1),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(7),
                            child: widget.data.image != null && widget.data.image!.trim().isNotEmpty
                                ? AuthenticatedImage(
                                    imageUrl: widget.data.image!.startsWith('http')
                                        ? widget.data.image!
                                        : '${ApiConfig.baseUrl}${widget.data.image}',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorWidget: Container(
                                      width: 40,
                                      height: 40,
                                      color: odaBackground,
                                      child: Icon(
                                        Icons.person,
                                        size: 20,
                                        color: bodyText2,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 40,
                                    height: 40,
                                    color: odaBackground,
                                    child: Icon(
                                      Icons.person,
                                      size: 20,
                                      color: bodyText2,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim().isNotEmpty 
                                    ? "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim()
                                    : 'Unknown User',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: bodyText1,
                                ),
                              ),
                              if (status.createdTime != null && status.createdTime!.trim().isNotEmpty)
                                Text(
                                  _safeConvertDate(status.createdTime) != '' 
                                      ? _safeConvertDate(status.createdTime)
                                      : status.createdTime!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: bodyText2.withOpacity(0.7),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      status.status!,
                      style: TextStyle(
                        fontSize: 15,
                        color: bodyText2,
                        height: 1.5,
                      ),
                    ),
                    if (status.attachment != null && status.attachment!.trim().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AuthenticatedImage(
                            imageUrl: status.attachment!.startsWith('http')
                                ? status.attachment!
                                : '${ApiConfig.baseUrl}${status.attachment}',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}
