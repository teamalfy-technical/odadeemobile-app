import 'dart:convert';
import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/Authentication/SignIn/sgin_in_screen.dart';
import 'package:odadee/Screens/Authentication/SignUp/sign_up_2.dart';
import 'package:odadee/components/keyboard_utils.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';
import 'package:odadee/services/year_group_service.dart';

class RegisterResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? user;

  RegisterResult({required this.success, this.error, this.user});
}

Future<RegisterResult> registerUser(Map<String, dynamic> data) async {
  try {
    final authService = AuthService();
    
    // Parse graduation year as integer
    int graduationYear;
    if (data['graduationYear'] is int) {
      graduationYear = data['graduationYear'];
    } else {
      graduationYear = int.tryParse(data['graduationYear']?.toString() ?? '') ?? 0;
    }
    
    final result = await authService.register(
      email: data['email'],
      password: data['password'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      graduationYear: graduationYear,
      phoneNumber: data['phoneNumber'],
    );

    return RegisterResult(success: true, user: result['user']);
  } catch (e) {
    debugPrint('Registration error: $e');
    String errorMessage = e.toString().replaceAll('Exception: ', '');
    return RegisterResult(success: false, error: errorMessage);
  }
}

class SignUp1 extends StatefulWidget {
  const SignUp1({
    super.key,
  });

  @override
  State<SignUp1> createState() => _SignUp1State();
}

class _SignUp1State extends State<SignUp1> {
  TextEditingController controller = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();
  Future<RegisterResult>? _futureSignUp;

  bool show_password = false;

  bool hasError = false;

  FocusNode focusNode = FocusNode();

  String? fcm_token;
  String? platformType;

  String? _selectedCountry;
  String? yearGroup;
  String? username;
  String? firstName;
  String? middleName;
  String? lastName;
  String? email;
  String? password;

  List<YearGroup> _yearGroups = [];
  bool _loadingYearGroups = true;

  /* get_fcm_token() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    log("FCMToken $fcmToken");
    fcm_token = fcmToken.toString();

  }*/

  String getPlatformType() {
    if (kIsWeb) {
      return 'Web';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else {
      return 'Unknown';
    }
  }

  @override
  void initState() {
    super.initState();

    //get_fcm_token();

    platformType = getPlatformType();
    _fetchYearGroups();
  }

  Future<void> _fetchYearGroups() async {
    try {
      final yearGroupService = YearGroupService();
      final groups = await yearGroupService.getPublicYearGroups();
      if (mounted) {
        setState(() {
          _yearGroups = groups;
          _loadingYearGroups = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching year groups: $e');
      if (mounted) {
        setState(() {
          _loadingYearGroups = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_futureSignUp == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
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
                height: 20,
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _formKey,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Let's get started",
                                style: TextStyle(fontSize: 34),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Country",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      showCountryPicker(
                                          context: context,
                                          showPhoneCode: true,
                                          onSelect: (Country country) {
                                            setState(() {
                                              _selectedCountry = country.name;
                                            });
                                          },
                                          countryListTheme:
                                              CountryListThemeData(
                                                  backgroundColor:
                                                      odaBackground,
                                                  textStyle: TextStyle(
                                                      color: Colors.white),
                                                  searchTextStyle: TextStyle(
                                                      color: Colors.white),
                                                  inputDecoration:
                                                      InputDecoration(
                                                    hintText: 'Search',
                                                    hintStyle: TextStyle(
                                                        color: Colors.grey),
                                                    prefixIcon: Icon(
                                                        Icons.search,
                                                        color: Colors.grey),
                                                    border: OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: Colors.grey),
                                                    ),
                                                  )));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 55,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          //color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey
                                                  .withOpacity(0.4))),
                                      child: Row(
                                        children: [
                                          if (_selectedCountry != null) ...[
                                            Text(_selectedCountry.toString(),
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black)),
                                          ] else ...[
                                            Text("Select Country",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.grey
                                                        .withOpacity(1))),
                                          ]
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Graduation Year",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      //_selectGraduationYear(context);
                                      _showGraduationYearModal(context);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      width: MediaQuery.of(context).size.width,
                                      height: 60,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey
                                                  .withOpacity(0.4))),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            yearGroup ?? 'Select Year',
                                            style: TextStyle(
                                                fontSize: 15, color: bodyText2),
                                          ),
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 22,
                                            color: odaSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
                                    //hintText: 'Enter Username/Email',

                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                    labelText: "First Name",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: bodyText2),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    border: InputBorder.none,
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(225),
                                    PasteTextInputFormatter(),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'First name is required';
                                    }
                                    if (value.length < 3) {
                                      return 'First name too short';
                                    }

                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  onSaved: (value) {
                                    setState(() {
                                      firstName = value;
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
                                    //hintText: 'Enter Username/Email',

                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                    labelText: "Middle Name",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: bodyText2),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    border: InputBorder.none,
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(225),
                                    PasteTextInputFormatter(),
                                  ],
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  onSaved: (value) {
                                    setState(() {
                                      middleName = value;
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
                                    //hintText: 'Enter Username/Email',

                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                    labelText: "Last Name",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: bodyText2),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    border: InputBorder.none,
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(225),
                                    PasteTextInputFormatter(),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Last name is required';
                                    }
                                    if (value.length < 3) {
                                      return 'Last name too short';
                                    }

                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  onSaved: (value) {
                                    setState(() {
                                      lastName = value;
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
                                    //hintText: 'Enter Username/Email',

                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                    labelText: "Username",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: bodyText2),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    border: InputBorder.none,
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(225),
                                    PasteTextInputFormatter(),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Username is required';
                                    }
                                    if (value.length < 3) {
                                      return 'Username too short';
                                    }

                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  onSaved: (value) {
                                    setState(() {
                                      username = value;
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
                                    //hintText: 'Enter Username/Email',

                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                    labelText: "Email Address",
                                    labelStyle: TextStyle(
                                        fontSize: 15, color: bodyText2),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.4))),
                                    border: InputBorder.none,
                                  ),
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(225),
                                    PasteTextInputFormatter(),
                                  ],
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Email is required';
                                    }
                                    if (value.length < 3) {
                                      return 'Name too short';
                                    }
                                    String pattern =
                                        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                        r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
                                        r"{0,253}[a-zA-Z0-9])?)*$";
                                    RegExp regex = RegExp(pattern);
                                    if (!regex.hasMatch(value)) {
                                      return 'Enter a valid email address';
                                    }

                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  onSaved: (value) {
                                    setState(() {
                                      email = value.toString().toLowerCase();
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
                                      labelStyle: TextStyle(
                                          fontSize: 15, color: bodyText2),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey
                                                  .withOpacity(0.4))),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey
                                                  .withOpacity(0.4))),
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
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
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
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    }),
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
                                      labelText: "Confirm Password",
                                      labelStyle: TextStyle(
                                          fontSize: 15, color: bodyText2),
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey
                                                  .withOpacity(0.4))),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.grey
                                                  .withOpacity(0.4))),
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

                                      if (value != password) {
                                        return 'Passwords do not match';
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
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    }),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 20,
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

                              print("##############");

                              var data = {
                                "firstName": firstName,
                                "lastName": lastName,
                                "email": email,
                                "password": password,
                                "graduationYear": yearGroup != null ? int.tryParse(yearGroup!) ?? 0 : 0,
                              };

                              _futureSignUp = registerUser(data);

                              print(data);

                              // Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SignUp2(data: _data)));
                            }
                          },
                          child: Align(
                            child: Container(
                              child: Text(
                                "Continue",
                                style: TextStyle(
                                    fontSize: 22, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              Align(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (BuildContext context) => SignInScreen()));
                  },
                  child: Text.rich(TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                      children: <InlineSpan>[
                        TextSpan(
                          text: "Sign In here",
                          style: TextStyle(
                              color: odaSecondary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        )
                      ])),
                ),
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  FutureBuilder<RegisterResult> buildFutureBuilder() {
    return FutureBuilder<RegisterResult>(
        future: _futureSignUp,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Please Wait...")
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data!;

            if (data.success && data.user != null) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignInScreen()));

                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: Text("Account Created Successfully")),
                          ],
                        ),
                        content: Text("Please sign in to continue."),
                      );
                    });
              });
            } else {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => SignUp1()));

                showDialog(
                    barrierDismissible: true,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text("Error"),
                          ],
                        ),
                        content: Text(data.error ??
                            "Registration failed. Please try again."),
                      );
                    });
              });
            }
          }

          return Scaffold(
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text("Please Wait...")
                ],
              ),
            ),
          );
        });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showGraduationYearModal(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 300,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: odaPrimary,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0))),
                height: 300,
              ),
              Positioned(
                top: 15,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        decoration:
                            BoxDecoration(color: Colors.grey.withOpacity(0.05)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Select Graduation Year",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      SizedBox(
                        //color: Colors.red,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            SizedBox(
                              height: 150, // Adjust the height as needed
                              child: _loadingYearGroups
                                  ? Center(child: CircularProgressIndicator())
                                  : _yearGroups.isEmpty
                                      ? Center(
                                          child: Text(
                                            'No year groups available',
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        )
                                      : ListView.builder(
                                          itemCount: _yearGroups.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            final group = _yearGroups[index];
                                            return InkWell(
                                              onTap: () {
                                                debugPrint(
                                                    group.year.toString());
                                                setState(() {
                                                  yearGroup =
                                                      group.year.toString();
                                                  Navigator.of(context).pop(
                                                      group.year.toString());
                                                });
                                              },
                                              child: SizedBox(
                                                height: 50,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      group.name,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    SizedBox(
                                                      width: 150,
                                                      child: Divider(
                                                        color: Colors.black,
                                                        thickness: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
