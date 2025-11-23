import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/Screens/AllUsers/models/all_users_model.dart';
import 'package:odadee/components/authenticated_image.dart';
import 'package:odadee/config/api_config.dart';
import 'package:odadee/constants.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Radio/playing_screen.dart';

class UserDetailScreen extends StatefulWidget {
  final Data data;
  const UserDetailScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {

  bool show_filter = false;
  String? graduation_year;
  final _formKey = GlobalKey<FormState>();

  bool is_info_page = true;

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
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          child: Stack(

            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              child:    InkWell(
                                onTap: (){
                                  Navigator.pop(context);
                                },
                                child: Container(

                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),


                                  ),
                                  child: Icon(Icons.arrow_back, color: odaSecondary, size: 30,),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("User Details", style: TextStyle(fontSize: 20, color: Colors.black),),
                          ],
                        ),
                        InkWell(
                          onTap: () {

                            if(show_filter){
                              setState(() {
                                show_filter = false;
                              });
                            }else {
                              setState(() {
                                show_filter = true;
                              });
                            }

                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                              color: odaPrimary,
                              borderRadius: BorderRadius.circular(5)

                            ),
                            child: Row(
                              children: [
                                Icon(Icons.chat_outlined, size: 15, color: Colors.white,),
                                SizedBox(
                                  width:3 ,
                                ),
                                Text("Message", style: TextStyle(color: Colors.white, fontSize: 14),)
                              ],
                            ),
                          ),
                        )
                      ],

                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            color: odaSecondary.withOpacity(0.2),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Container(
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Container(
                                            height: 210,
                                            width: 200,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                  colors: [
                                                    odaPrimary,
                                                    odaSecondary,
                                                  ]
                                              ),
                                              borderRadius: BorderRadius.circular(15)
                                            ),
                                          ),
                                          Positioned(
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              height: 180,
                                              width: 180,
                                              margin: EdgeInsets.only(left: 5, right: 5, top: 5),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(15),
                                                child: widget.data.image != null && widget.data.image!.trim().isNotEmpty
                                                    ? AuthenticatedImage(
                                                        imageUrl: widget.data.image!.startsWith('http')
                                                            ? widget.data.image!
                                                            : '${ApiConfig.baseUrl}${widget.data.image}',
                                                        width: 180,
                                                        height: 180,
                                                        fit: BoxFit.cover,
                                                        errorWidget: Container(
                                                          width: 180,
                                                          height: 180,
                                                          decoration: BoxDecoration(
                                                            color: odaPrimary.withOpacity(0.3),
                                                            borderRadius: BorderRadius.circular(15),
                                                          ),
                                                          child: Center(
                                                            child: Icon(
                                                              Icons.person,
                                                              size: 80,
                                                              color: Colors.white.withOpacity(0.7),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(
                                                        width: 180,
                                                        height: 180,
                                                        decoration: BoxDecoration(
                                                          color: odaPrimary.withOpacity(0.3),
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            Icons.person,
                                                            size: 80,
                                                            color: Colors.white.withOpacity(0.7),
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5,
                                              left: 0,
                                              right: 0,

                                              child: Container(
                                                //color: Colors.red,
                                                width: MediaQuery.of(context).size.width,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Year Group: ${widget.data.yearGroup ?? 'N/A'}", 
                                                      style: TextStyle(color: Colors.white, fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              )
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim().isNotEmpty 
                                            ? "${widget.data.firstName ?? ''} ${widget.data.lastName ?? ''}".trim()
                                            : 'Unknown User', 
                                        style: TextStyle(fontSize: 24, color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.facebook, size: 17,),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(Icons.facebook, size: 17),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Icon(Icons.facebook, size: 17),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: odaSecondary),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            is_info_page = true;
                                          });
                                        },
                                        child: Container(
                                          width: 170,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: is_info_page ? odaSecondary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Information",
                                              style: TextStyle(
                                                color: is_info_page ? Colors.white : odaSecondary,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            is_info_page = false;
                                          });
                                        },
                                        child: Container(
                                          width: 150,
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: !is_info_page ? odaSecondary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Status",
                                              style: TextStyle(
                                                color: !is_info_page ? Colors.white : odaSecondary,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          is_info_page ? _information() : _status(),







                        ],
                      ),
                    ),
                  )

                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: (){
                          /*      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()));
                      */  },
                        child: Column(
                          children: [
                            Icon(Icons.home, color: odaSecondary,),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Home', style: TextStyle(color: odaSecondary, fontSize: 12),),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => RadioScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(Icons.radio, color: Colors.grey),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Radio', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){
                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => PayDuesScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(Icons.phone_android, color: Colors.grey,),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Pay Dues', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){

                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SettingsScreen()));

                        },
                        child: Column(
                          children: [
                            Icon(Icons.settings, color: Colors.grey,),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Settings', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: (){

                          Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => UserProfileScreen()));

                        },
                        child: Column(
                          children: [
                            Icon(Icons.person, color: Colors.grey,),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Profile', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _information(){
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                    'Bio',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    colors: [
                      odaPrimary,
                      odaSecondary,
                    ]
                ),
                SizedBox(
                  height: 5,
                ),
                Text(widget.data.about ?? 'No bio available', style: TextStyle(fontSize: 18),),

              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                    'Contact Information',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    colors: [
                      odaPrimary,
                      odaSecondary,
                    ]
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("Nick Name:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Text(widget.data.nickName ?? 'N/A', style: TextStyle(fontSize: 18),),

                  ],
                ),
                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("url:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Text(widget.data.website ?? 'N/A', style: TextStyle(fontSize: 18, color: odaSecondary),),

                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("email:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Expanded(child: Text(widget.data.email ?? 'N/A', style: TextStyle(fontSize: 18, ),)),

                  ],
                ),



                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("PIN:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Text(widget.data.pin ?? 'N/A', style: TextStyle(fontSize: 18, ),),

                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("Skype ID:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Text(widget.data.skypeUrl ?? 'N/A', style: TextStyle(fontSize: 18,),),

                  ],
                ),





              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(15.0),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GradientText(
                    'General information',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                    colors: [
                      odaPrimary,
                      odaSecondary,
                    ]
                ),
                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("Profession:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Expanded(child: Text(widget.data.position ?? 'N/A', style: TextStyle(fontSize: 18, ),)),

                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("Job Title:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Expanded(child: Text(widget.data.jobTitle ?? 'N/A', style: TextStyle(fontSize: 18, ),)),

                  ],
                ),


                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("Place of work:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Expanded(child: Text(widget.data.workPlace ?? 'N/A', style: TextStyle(fontSize: 18, ),)),

                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("House:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Expanded(child: Text(widget.data.house ?? 'N/A', style: TextStyle(fontSize: 18, ),)),

                  ],
                ),

                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("City:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Expanded(child: Text(widget.data.city ?? 'N/A', style: TextStyle(fontSize: 18, ),)),

                  ],
                ),


                SizedBox(
                  height: 10,
                ),

                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                        width: 150,
                        child: Text("Status:", style: TextStyle(fontSize: 18, color: Colors.grey.withOpacity(0.9)),)),

                    Expanded(child: Text(widget.data.status ?? 'N/A', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black ),)),

                  ],
                ),


                SizedBox(
                  height: 100,
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }



  Widget _status(){
    return  Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height,
          child: widget.data.userStatus != null && widget.data.userStatus!.isNotEmpty
              ? ListView.builder(
            itemCount: widget.data.userStatus!.length,
              itemBuilder: (context, index){
                final statusItem = widget.data.userStatus![index];
                if (statusItem == null) return SizedBox.shrink();
                
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Column(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: odaPrimary,
                                      radius: 5,
                                    ),
                                    Container(
                                      height: 30,
                                      width: 1,
                                      decoration: BoxDecoration(
                                        color: odaSecondary
                                      ),
                                    )
                                  ],
                                ),
                                Container(
                                  width: 20,

                                  decoration: BoxDecoration(
                                      color: odaPrimary
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,

                                children: [
                                  Text(statusItem.status ?? '', style: TextStyle(fontSize: 16),),
                                  if(statusItem.attachment != null && 
                                     statusItem.attachment!.trim().isNotEmpty)...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: AuthenticatedImage(
                                        imageUrl: statusItem.attachment!.startsWith('http')
                                            ? statusItem.attachment!
                                            : '${ApiConfig.baseUrl}${statusItem.attachment}',
                                        width: 150,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorWidget: Container(
                                          width: 150,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            color: odaSecondary.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ],
                                  Builder(
                                    builder: (context) {
                                      final dateStr = _safeConvertDate(statusItem.createdTime);
                                      return dateStr.isNotEmpty
                                          ? Text(dateStr, style: TextStyle(fontSize: 16,color: Colors.grey.withOpacity(0.9)))
                                          : SizedBox.shrink();
                                    },
                                  ),

                                ],
                              ),
                            )
                          ],
                        ),


                      ],
                    ),

                  ),
                );
              }
          )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No status updates',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
        ),



      ],
    );
  }



}
