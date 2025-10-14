import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/Authentication/SignUp/models/update_bio_model.dart';
import 'package:odadee/constants.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../SignIn/sgin_in_screen.dart';

Future<UpdateBioModel> updateBio(bio, interests, user) async {
  final response = await http.post(
    Uri.parse(hostName + "/api/update-bio"),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json'
    },
    body: jsonEncode({
      "user": user,
      "shortBio": bio,
      "interests": interests,
    }),
  );

  if (response.statusCode == 200) {
    print(jsonDecode(response.body));
    final result = json.decode(response.body);
    if (result != null) {
      //print(result['meta']['token'].toString());
      //await saveIDApiKey(result['meta']['token'].toString());
    }
    return UpdateBioModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 203) {
    print(jsonDecode(response.body));
    return UpdateBioModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 403) {
    print(jsonDecode(response.body));
    return UpdateBioModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 422) {
    print(jsonDecode(response.body));
    return UpdateBioModel.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to Update Bio');
  }
}

class SignUp4 extends StatefulWidget {
  final data;
  final user_data;

  const SignUp4({Key? key, required this.data, required this.user_data})
      : super(key: key);

  @override
  State<SignUp4> createState() => _SignUp4State();
}

class _SignUp4State extends State<SignUp4> {
  TextEditingController controller = TextEditingController(text: "");

  final _formKey = GlobalKey<FormState>();
  Future<UpdateBioModel>? _futureUpdateBio;

  FocusNode focusNode = FocusNode();

  List _interests = [];
  String? filePath;
  File? file;

  @override
  void initState() {
    _interests = widget.data['interests[]'];
    filePath = widget.user_data.image;
    file = File(filePath!);
  }

  @override
  Widget build(BuildContext context) {
    return (_futureUpdateBio == null) ? buildColumn() : buildFutureBuilder();
  }

  buildColumn() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                ),
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
                      width: 20,
                    ),
                    Text(
                      "Welcome to the Team",
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Form(
                        key: _formKey,
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: 100,
                                    width: 100,
                                    decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(widget
                                              .user_data.image
                                              .toString()),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GradientText(
                                            widget.user_data.firstName +
                                                " " +
                                                widget.user_data.lastName,
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.w900),
                                            colors: [
                                              odaPrimary,
                                              odaSecondary,
                                            ]),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          widget.user_data.email,
                                          style: TextStyle(),
                                        ),
                                        SizedBox(
                                          height: 3,
                                        ),
                                        Text(
                                          widget.user_data.yearGroup,
                                          style: TextStyle(),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GradientText('Bio',
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
                                    Text(
                                      widget.data['shortBio'].toString(),
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GradientText('Your Interest',
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
                                  Container(
                                    child: Wrap(
                                      children: _interests!
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        final index = entry.key;
                                        final interest = entry.value;
                                        return Container(
                                          padding: EdgeInsets.all(8),
                                          margin: EdgeInsets.all(5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(interest),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                            color: odaBorder,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
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
                              print("#######");

                              setState(() {
                                _futureUpdateBio = updateBio(
                                    widget.data['shortBio'],
                                    _interests,
                                    widget.user_data.email);
                              });
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
                    SizedBox(
                      height: 20,
                    ),
                    /*  Align(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (BuildContext context) =>
                                  SignInScreen()));
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
                    ),*/
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

  FutureBuilder<UpdateBioModel> buildFutureBuilder() {
    return FutureBuilder<UpdateBioModel>(
        future: _futureUpdateBio,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Container(
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

            print("#########################");
            print(data.toJson());

            if (data.message == "Bio Updated Successfully") {
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
                                child: Text("Your Account has been Created")),
                          ],
                        ),
                        content: Text("Profile Updated Succesfully"),
                      );
                    });
              });
            }
          }

          return Scaffold(
            body: Container(
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

  void dispose() {
    super.dispose();
  }
}
