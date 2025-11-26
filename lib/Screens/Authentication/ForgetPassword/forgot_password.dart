import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/Authentication/ForgetPassword/reset_password.dart';
import 'package:odadee/Screens/Authentication/SignIn/model/sign_in_model.dart';
import 'package:odadee/components/keyboard_utils.dart';
import 'package:odadee/constants.dart';
import 'package:odadee/services/auth_service.dart';

class PasswordResetResult {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  PasswordResetResult({
    required this.success,
    required this.message,
    this.data,
  });
}

Future<PasswordResetResult> requestPasswordReset(String email) async {
  try {
    final authService = AuthService();
    final result = await authService.requestPasswordReset(email);
    
    return PasswordResetResult(
      success: result['success'] == true,
      message: result['message'] ?? 'Request sent',
      data: result,
    );
  } catch (e) {
    return PasswordResetResult(
      success: false,
      message: e.toString().replaceAll('Exception: ', ''),
    );
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool show_password = false;
  Future<PasswordResetResult>? _futurePasswordReset;

  final _formKey = GlobalKey<FormState>();

  String? email;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return (_futurePasswordReset == null) ? buildColumn() : buildFutureBuilder();
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
                        SizedBox(
                          height: 40,
                        ),
                        Text(
                          "Forgot your Password?",
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
                                email = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: 20,
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
                                  _futurePasswordReset = requestPasswordReset(email!);
                                });
                              }
                            },
                            child: Align(
                              child: Container(
                                child: Text(
                                  "Reset Password",
                                  style: TextStyle(
                                      fontSize: 22, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
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

  FutureBuilder<PasswordResetResult> buildFutureBuilder() {
    return FutureBuilder<PasswordResetResult>(
      future: _futurePasswordReset,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Sending password reset link...")
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final result = snapshot.data!;
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (result.success) {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 10),
                        Text("Success"),
                      ],
                    ),
                    content: Text(result.message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Text("Back to Login"),
                      ),
                    ],
                  ),
                );
              } else {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Error"),
                      ],
                    ),
                    content: Text(result.message),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() => _futurePasswordReset = null);
                        },
                        child: Text("Try Again"),
                      ),
                    ],
                  ),
                );
              }
            });

            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }

        return buildColumn();
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
