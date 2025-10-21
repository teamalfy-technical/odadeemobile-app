import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/Authentication/ForgetPassword/forgot_password.dart';
import 'package:odadee/Screens/Authentication/SignUp/sign_up_2.dart';
import 'package:odadee/Screens/Dashboard/dashboard_screen.dart';
import 'package:odadee/components/keyboard_utils.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? user;
  
  LoginResult({required this.success, this.error, this.user});
}

Future<LoginResult> signInUser(String email, String password) async {
  try {
    final authService = AuthService();
    final result = await authService.login(email, password);
    
    final user = result['user'];
    await saveUserData(user);
    
    try {
      await fetchDataFromServer();
    } catch (e) {
      debugPrint('Settings fetch error (non-critical): $e');
    }
    
    return LoginResult(success: true, user: user);
  } catch (e) {
    debugPrint('Login error: $e');
    String errorMessage = e.toString().replaceAll('Exception: ', '');
    return LoginResult(success: false, error: errorMessage);
  }
}

Future<void> fetchDataFromServer() async {
  try {
    final authService = AuthService();
    final response = await authService.authenticatedRequest('GET', '/api/settings');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final pushNotificationValue = jsonData['setting']['push_notification'];
      await saveSettings(pushNotificationValue);
    }
  } catch (e) {
    debugPrint('Fetch settings error: $e');
  }
}

Future<bool> saveSettings(int notification) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("notification", notification);
  return prefs.commit();
}

Future<bool> saveUserData(Map<String, dynamic> userData) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  prefs.setString("YearGroup", userData['yearGroupId']?.toString() ?? '');
  prefs.setString("image", userData['profilePicture']?.toString() ?? '');
  prefs.setString("email", userData['email']?.toString() ?? '');
  prefs.setString("phone", userData['phone']?.toString() ?? '');
  prefs.setString("firstName", userData['firstName']?.toString() ?? '');
  prefs.setString("middleName", '');
  prefs.setString("lastName", userData['lastName']?.toString() ?? '');
  prefs.setString("USER_ID", userData['id']?.toString() ?? '');
  prefs.setString("role", userData['role']?.toString() ?? '');
  
  return prefs.commit();
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool show_password = false;
  Future<LoginResult>? _futureSignIn;

  final _formKey = GlobalKey<FormState>();

  String? user;
  String? password;

  @override
  Widget build(BuildContext context) {
    return (_futureSignIn == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            //color: Colors.red,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage(
                            'assets/images/odadee_logo_1.png',
                          ),
                          height: 120,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          "We trudge along to Happy Victory",
                          style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w400,
                              color: bodyText1),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              //color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.4))),
                          child: TextFormField(
                            style: TextStyle(),
                            decoration: InputDecoration(
                              //hintText: 'Enter Username/Email',

                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal),
                              labelText: "Username/Email",
                              labelStyle:
                                  TextStyle(fontSize: 15, color: bodyText2),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.4))),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.4))),
                              border: InputBorder.none,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(225),
                              PasteTextInputFormatter(),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Email/Username is required';
                              }
                              if (value.length < 3) {
                                return 'Email/Username too short';
                              }
                              /*  String pattern =
                                  r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                  r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                  r"{0,253}[a-zA-Z0-9])?)*$";
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value))
                                return 'Enter a valid email address';
        */
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            onSaved: (value) {
                              setState(() {
                                user = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              //color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.4))),
                          child: TextFormField(
                            style: TextStyle(),
                            decoration: InputDecoration(
                              //hintText: 'Enter Password',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    show_password = !show_password;
                                  });
                                },
                                icon: Icon(
                                  show_password
                                      ? Icons.remove_red_eye_outlined
                                      : Icons.remove_red_eye,
                                  color: odaSecondary,
                                ),
                              ),
                              hintStyle: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.normal),
                              labelText: "Password",
                              labelStyle:
                                  TextStyle(fontSize: 15, color: bodyText2),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.4))),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.grey.withOpacity(0.4))),
                              border: InputBorder.none,
                            ),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(225),
                              PasteTextInputFormatter(),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Password is required';
                              }
                              if (!RegExp(
                                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$%^&*])')
                                  .hasMatch(value)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        "- Password must be at least 8 characters long\n- Must include at least one uppercase letter,\n- One lowercase letter, one digit,\n- And one special character"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return '';
                              }
                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            obscureText: show_password ? false : true,
                            onSaved: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ForgotPasswordScreen()));
                                },
                                child: Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: odaSecondary,
                                  ),
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    Align(
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
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                KeyboardUtil.hideKeyboard(context);

                                setState(() {
                                  _futureSignIn = signInUser(user!, password!);
                                });
                              }
                            },
                            child: Align(
                              child: Container(
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Align(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text.rich(TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                            children: <InlineSpan>[
                              TextSpan(
                                text: "Sign Up here",
                                style: TextStyle(
                                    color: odaSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              )
                            ])),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FutureBuilder<LoginResult> buildFutureBuilder() {
    return FutureBuilder<LoginResult>(
      future: _futureSignIn,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            var data = snapshot.data!;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleNavigationAndDialogs(context, data);
            });

            return SizedBox();
          } else if (snapshot.hasError) {
            debugPrint("ERROR: ${snapshot.error}");
            return SizedBox();
          } else {
            return _buildErrorWidget("No data found");
          }
        }

        return _buildLoadingWidget();
      },
    );
  }

  void _handleNavigationAndDialogs(BuildContext context, LoginResult data) {
    if (data.success && data.user != null) {
      final user = data.user!;
      final hasProfilePicture = user['profilePicture'] != null && user['profilePicture'].toString().isNotEmpty;
      final hasBio = user['bio'] != null && user['bio'].toString().isNotEmpty;
      
      if (!user['isActive']) {
        _navigateToSignIn(context);
        _showDialog(context, "Error", "Your profile is not active", 
            Icons.close, Colors.red);
      } else if (!hasProfilePicture || !hasBio) {
        _showDialog(
            context,
            "Success",
            "Please update your profile and proceed.",
            Icons.check_circle,
            Colors.green);
        Future.delayed(Duration(milliseconds: 500), () {
          _navigateToDashboard(context);
        });
      } else {
        _showDialog(context, "Success", "User logged in successfully.",
            Icons.check_circle, Colors.green);
        Future.delayed(Duration(milliseconds: 500), () {
          _navigateToDashboard(context);
        });
      }
    } else {
      _navigateToSignIn(context);
      _showDialog(
          context, "Error", data.error ?? "Login failed. Please try again.", 
          Icons.close, Colors.red);
    }
  }

// Loading widget
  Widget _buildLoadingWidget() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Please Wait...")
          ],
        ),
      ),
    );
  }

// Error widget
  Widget _buildErrorWidget(String message) {
    return Scaffold(
      body: Center(child: Text(message)),
    );
  }

// Dialog helper
  void _showDialog(BuildContext context, String title, String content,
      IconData icon, Color iconColor) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(icon, color: iconColor),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
          content: Text(content),
        );
      },
    );
  }

// Navigation helpers
  void _navigateToSignIn(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => SignInScreen()));
  }


  void _navigateToDashboard(BuildContext context) {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => DashboardScreen()));
  }

  // FutureBuilder<SignInModel> buildFutureBuilder() {
  //   return FutureBuilder<SignInModel>(
  //       future: _futureSignIn,
  //       builder: (context, snapshot) {
  //         print('ConnectionState : ${snapshot.connectionState}');
  //         print('Data : ${snapshot.data}');
  //         print('HasData : ${snapshot.hasData}');
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return _buildLoadingWidget();
  //         } else if (snapshot.connectionState == ConnectionState.done &&
  //             snapshot.hasData) {
  //           var data = snapshot.data!;

  //           print("#########################");
  //           print(data.error);
  //           print(data.token);

  //           if (data.error == "Your profile is not active") {
  //             WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //               Navigator.pushReplacement(context,
  //                   MaterialPageRoute(builder: (context) => SignInScreen()));

  //               showDialog(
  //                   barrierDismissible: true,
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return AlertDialog(
  //                       title: Row(
  //                         children: [
  //                           Icon(
  //                             Icons.check_circle,
  //                             color: Colors.green,
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Text("Error"),
  //                         ],
  //                       ),
  //                       content: Text(data.error.toString()),
  //                     );
  //                   });
  //             });
  //           } else if (data.token != null) {
  //             if (data.userData!.hasBio == false ||
  //                 data.userData!.hasImage == false) {
  //               WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //                 showDialog(
  //                     barrierDismissible: true,
  //                     context: context,
  //                     builder: (BuildContext context) {
  //                       return AlertDialog(
  //                         title: Row(
  //                           children: [
  //                             Icon(
  //                               Icons.check_circle,
  //                               color: Colors.green,
  //                             ),
  //                             SizedBox(
  //                               width: 10,
  //                             ),
  //                             Text("Success"),
  //                           ],
  //                         ),
  //                         content:
  //                             Text("Please Update your profile and proceed."),
  //                       );
  //                     });

  //                 Navigator.pushReplacement(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => SignUp2(data: data.userData!)));
  //               });
  //             } else {
  //               WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //                 showDialog(
  //                     barrierDismissible: true,
  //                     context: context,
  //                     builder: (BuildContext context) {
  //                       // Show the dialog
  //                       return AlertDialog(
  //                         title: Row(
  //                           children: [
  //                             Icon(Icons.check_circle, color: Colors.green),
  //                             SizedBox(width: 10),
  //                             Text("Success"),
  //                           ],
  //                         ),
  //                         content: Text("User logged in successfully."),
  //                       );
  //                     });
  //                 Future.delayed(Duration(milliseconds: 500), () {
  //                   // Pop the dialog
  //                   //Navigator.of(context).pop();

  //                   // Navigate to the dashboard
  //                   Navigator.pushReplacement(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => DashboardScreen()),
  //                   );
  //                 });

  //                 // Delay the navigation by 2 seconds
  //                 /*Future.delayed(Duration(seconds: 1), () {
  //                   // Pop the dialog
  //                   //Navigator.of(context).pop();

  //                   // Navigate to the dashboard
  //                   Navigator.pushReplacement(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => DashboardScreen()),
  //                   );
  //                 });*/
  //               });
  //             }
  //           } else if (data.error == "Please enter a valid Username or Email") {
  //             WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //               Navigator.pushReplacement(context,
  //                   MaterialPageRoute(builder: (context) => SignInScreen()));

  //               showDialog(
  //                   barrierDismissible: true,
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return AlertDialog(
  //                       title: Row(
  //                         children: [
  //                           Icon(
  //                             Icons.close,
  //                             color: Colors.red,
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Text("Error"),
  //                         ],
  //                       ),
  //                       content: Text(data.error.toString()),
  //                     );
  //                   });
  //             });
  //           } else if (data.error == "Please enter the valid Password.") {
  //             WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //               Navigator.pushReplacement(context,
  //                   MaterialPageRoute(builder: (context) => SignInScreen()));

  //               showDialog(
  //                   barrierDismissible: true,
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return AlertDialog(
  //                       title: Row(
  //                         children: [
  //                           Icon(
  //                             Icons.close,
  //                             color: Colors.red,
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Text("Error"),
  //                         ],
  //                       ),
  //                       content: Text(data.error.toString()),
  //                     );
  //                   });
  //             });
  //           } else if (data.error == "Your Login attempts is over") {
  //             WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //               Navigator.pushReplacement(context,
  //                   MaterialPageRoute(builder: (context) => SignInScreen()));

  //               showDialog(
  //                   barrierDismissible: true,
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return AlertDialog(
  //                       title: Row(
  //                         children: [
  //                           Icon(
  //                             Icons.close,
  //                             color: Colors.red,
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Text("Error"),
  //                         ],
  //                       ),
  //                       content: Text(data.error.toString()),
  //                     );
  //                   });
  //             });
  //           }
  //         }

  //         return _buildLoadingWidget();

  //       });
  // }

  // Widget _buildLoadingWidget(){
  //   return Scaffold(
  //           body: SizedBox(
  //             width: MediaQuery.of(context).size.width,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 CircularProgressIndicator(),
  //                 SizedBox(
  //                   height: 10,
  //                 ),
  //                 Text("Please Wait...")
  //               ],
  //             ),
  //           ),
  //         );
  // }

  @override
  void dispose() {
    super.dispose();
  }
}
