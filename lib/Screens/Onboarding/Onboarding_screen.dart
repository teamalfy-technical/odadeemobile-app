import 'package:flutter/material.dart';
import 'package:odadee/Screens/Authentication/SignIn/sgin_in_screen.dart';
import 'package:odadee/Screens/Authentication/SignUp/sign_up_1.dart';
import 'package:odadee/constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/odadee_logo_1.png",
                      height: 120,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Hi there,",
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.normal),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Welcome to the\nƆdadeɛ App!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: odaPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Your alumni community, in your pocket. People, events, and support. All in one place.",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext context) => SignUp1()));
                          },
                          child: Align(
                            child: Container(
                              child: Text(
                                "Get Started",
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
                        Navigator.of(context).push(MaterialPageRoute(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
