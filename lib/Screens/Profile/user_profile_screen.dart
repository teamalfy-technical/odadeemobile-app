import 'package:flutter/material.dart';
import 'package:odadee/Screens/Authentication/SignIn/sgin_in_screen.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Dashboard/dashboard_screen.dart';
import '../Radio/playing_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String? userYearGroup;
  String? userImage;
  String? firstName;
  String? middleName;
  String? lastName;
  String? email;
  String? phone;

  @override
  void initState() {
    super.initState();
    getUserData().then((userData) {
      // Use the user data retrieved from shared preferences.
      // You can set it to your local state or display it as needed.
      setState(() {
        userYearGroup = userData["YearGroup"];
        userImage = userData["image"];
        firstName = userData["firstName"];
        middleName = userData["middleName"];
        lastName = userData["lastName"];
        email = userData["email"];
        phone = userData["phone"];
        // Set other user data variables as needed.
      });
    });
  }

  Future<Map<String, dynamic>> getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> userData = {
      "YearGroup": prefs.getString("YearGroup") ?? "",
      "image": prefs.getString("image") ?? "",
      "email": prefs.getString("email") ?? "",
      "phone": prefs.getString("phone") ?? "",
      "firstName": prefs.getString("firstName") ?? "",
      "middleName": prefs.getString("middleName") ?? "",
      "lastName": prefs.getString("lastName") ?? "",
    };
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      color: odaSecondary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: odaSecondary,
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Profile",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            ),
                            InkWell(
                              onTap: () {},
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                    color: odaPrimary,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chat_outlined,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      "Message",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14),
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                color: odaSecondary.withOpacity(0.1),
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
                                                    gradient:
                                                        LinearGradient(colors: [
                                                      odaPrimary,
                                                      odaSecondary,
                                                    ]),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15)),
                                              ),
                                              Positioned(
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 180,
                                                  width: 180,
                                                  margin: EdgeInsets.only(
                                                      left: 5,
                                                      right: 5,
                                                      top: 5),
                                                  decoration: BoxDecoration(
                                                      //color: Colors.black,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      image: DecorationImage(
                                                          image: NetworkImage(
                                                              userImage
                                                                  .toString()),
                                                          fit: BoxFit.cover)),
                                                ),
                                              ),
                                              Positioned(
                                                  bottom: 5,
                                                  left: 0,
                                                  right: 0,
                                                  child: SizedBox(
                                                    //color: Colors.red,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Year Group: $userYearGroup",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Text(
                                      "$firstName $middleName $lastName",
                                      style: TextStyle(fontSize: 24),
                                    )
                                  ],
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GradientText('Contact Information',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900),
                                          colors: [
                                            odaPrimary,
                                            odaSecondary,
                                          ]),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                              width: 150,
                                              child: Text(
                                                "email:",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey
                                                        .withOpacity(0.9)),
                                              )),
                                          Expanded(
                                              child: Text(
                                            "$email",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                              width: 150,
                                              child: Text(
                                                "Phone:",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.grey
                                                        .withOpacity(0.9)),
                                              )),
                                          Text(
                                            "$phone",
                                            style: TextStyle(
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // SizedBox(
                              //   height: 60,
                              // ),

                              // Padding(
                              //   padding: const EdgeInsets.all(20.0),
                              //   child: Align(
                              //     child: Container(
                              //       width: MediaQuery.of(context).size.width,
                              //       padding: EdgeInsets.all(15),
                              //       decoration: BoxDecoration(
                              //           color: odaSecondary,
                              //           borderRadius: BorderRadius.circular(10)),
                              //       child: Material(
                              //         color: Colors.transparent,
                              //         child: InkWell(
                              //           onTap: () {

                              //             logout();
                              //             // Navigate to the login or home screen as needed.
                              //             Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) =>
                              //                 SignInScreen()), (Route<dynamic> route) => false);

                              //           },
                              //           child: Align(
                              //             child: Container(
                              //               child: Text(
                              //                 "Logout",
                              //                 style: TextStyle(
                              //                     fontSize: 22, color: Colors.white),
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Align(
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              color: odaSecondary,
                              borderRadius: BorderRadius.circular(10)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                logout();
                                // Navigate to the login or home screen as needed.
                                Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) => SignInScreen()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Align(
                                child: Container(
                                  child: Text(
                                    "Logout",
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
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
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                DashboardScreen()));
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.home,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            'Home',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) => RadioScreen()));
                      },
                      child: Column(
                        children: [
                          Icon(Icons.radio, color: Colors.grey),
                          SizedBox(
                            height: 4,
                          ),
                          Text('Radio',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                PayDuesScreen()));
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.phone_android,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text('Pay Dues',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                SettingsScreen()));
                      },
                      child: Column(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text('Settings',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Column(
                        children: [
                          Icon(
                            Icons.person,
                            color: odaSecondary,
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text('Profile',
                              style:
                                  TextStyle(color: odaSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("API_Key"); // Remove the API key (token)
    await prefs.remove("YearGroup");
    await prefs.remove("image");
    await prefs.remove("email");
    await prefs.remove("phone");
    await prefs.remove("firstName");
    await prefs.remove("middleName");
    await prefs.remove("lastName");
  }
}
