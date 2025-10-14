import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odadee/Screens/Authentication/SignUp/sign_up_4.dart';
import 'package:odadee/components/keyboard_utils.dart';
import 'package:odadee/constants.dart';

class SignUp3 extends StatefulWidget {
  final data;

  const SignUp3({Key? key, required this.data}) : super(key: key);

  @override
  State<SignUp3> createState() => _SignUp3State();
}

class _SignUp3State extends State<SignUp3> {
  TextEditingController? _controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  List<String> interests = [];
  String? shortBio;

  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
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
                                "Welcome",
                                style: TextStyle(fontSize: 27),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                widget.data.firstName +
                                    " " +
                                    widget.data.lastName,
                                style: TextStyle(
                                    fontSize: 34, fontWeight: FontWeight.w900),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text.rich(TextSpan(
                                  text: "Now it’s time, ",
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  children: <InlineSpan>[
                                    TextSpan(
                                      text: widget.data.firstName +
                                          " " +
                                          widget.data.lastName,
                                      style: TextStyle(
                                          color: odaPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900),
                                    ),
                                    TextSpan(
                                      text: " to make your profile glow!",
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    )
                                  ])),
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
                                  maxLines: 4,
                                  style: TextStyle(),
                                  decoration: InputDecoration(
                                    //hintText: 'Enter Username/Email',

                                    hintStyle: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.normal),
                                    labelText: "Write a short bio that rocks",
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
                                      return 'Bio is required';
                                    }
                                    if (value.length < 3) {
                                      return 'Bio too short';
                                    }

                                    return null;
                                  },
                                  textInputAction: TextInputAction.next,
                                  autofocus: false,
                                  onSaved: (value) {
                                    setState(() {
                                      shortBio = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                          //color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          border: Border.all(
                                              color: Colors.grey
                                                  .withOpacity(0.4))),
                                      child: TextFormField(
                                        controller: _controller,
                                        style: TextStyle(),
                                        decoration: InputDecoration(
                                          //hintText: 'Enter Username/Email',

                                          hintStyle: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.normal),
                                          labelText: "Share some interests",
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
                                        textInputAction: TextInputAction.next,
                                        autofocus: false,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      final text = _controller!.text.trim();
                                      if (text.isNotEmpty) {
                                        setState(() {
                                          interests.add(text);
                                          _controller!
                                              .clear(); // Clear the input field
                                        });
                                      }
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: odaSecondary,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding: EdgeInsets.all(18),
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 25,
                                        )),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Container(
                                child: Wrap(
                                  children:
                                      interests.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final interest = entry.value;
                                    return Container(
                                      padding: EdgeInsets.all(8),
                                      margin: EdgeInsets.all(5),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(interest),
                                          SizedBox(width: 10),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                interests.removeAt(
                                                    index); // Remove the interest at the given index
                                              });
                                            },
                                            child: Container(
                                              width: 25,
                                              padding: EdgeInsets.all(2),
                                              child: Center(
                                                  child: Text("x",
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white))),
                                              decoration: BoxDecoration(
                                                color: odaSecondary
                                                    .withOpacity(0.3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      decoration: BoxDecoration(
                                        color: odaBorder,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                if (interests.isNotEmpty) ...[
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

                                  print("##########");
                                  //widget.data['shortBio'] = shortBio;
                                  //widget.data['interests'] = interests.toString();

                                  var _data = {
                                    "shortBio": shortBio,
                                    "interests[]": interests,
                                  };

                                  //print(widget.data);

                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          SignUp4(
                                              data: _data,
                                              user_data: widget.data)));
                                }

                                //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SignUp4()));
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
                      /*   Align(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => SignInScreen()));
        
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
                ],
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
}
