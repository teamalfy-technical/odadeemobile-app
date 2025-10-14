import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:odadee/Screens/Dashboard/dashboard_screen.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/constants.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Radio/playing_screen.dart';

class PayDuesScreen extends StatefulWidget {
  const PayDuesScreen({Key? key}) : super(key: key);

  @override
  State<PayDuesScreen> createState() => _PayDuesScreenState();
}

class _PayDuesScreenState extends State<PayDuesScreen> {

  bool show_password = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        //padding: EdgeInsets.all(20),
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Pay Dues", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.black),  ),

                      Stack(
                        children: [
                          Icon(Icons.notifications_none_outlined, color: odaSecondary, size: 30,),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: odaSecondary,
                              radius: 5,
                            ),
                          )
                        ],
                      )
                    ],

                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [

                        Container(

                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(50),
                            image: DecorationImage(
                              image: AssetImage("assets/images/paydues.png"),
                              fit: BoxFit.cover
                            )
                          ),
                        ),


                        SizedBox(
                          height: 20,
                        ),
                        GradientText("Payment", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: odaPrimary), colors: [
                          odaPrimary,
                          odaSecondary,
                        ]),
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
                              labelText: "Amount",
                              labelStyle:
                              TextStyle(fontSize: 15, color: bodyText2),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.4))),
                              border: InputBorder.none,),
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(225),
                              PasteTextInputFormatter(),
                            ],
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Amount is required';
                              }


                              return null;
                            },
                            textInputAction: TextInputAction.next,
                            autofocus: false,
                            onSaved: (value) {
                              setState(() {

                              });
                            },
                          ),
                        ),

                        SizedBox(
                          height: 20,
                        ),

                        Text("Secured payment", style: TextStyle(fontSize: 16, color: bodyText1), ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          children: [
                            Expanded(child: Image(image: AssetImage("assets/images/card1.png"))),
                            Expanded(child: Image(image: AssetImage("assets/images/card2.png"))),

                          ],
                        ),






                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
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
                                _payDuesModal(context);
                              },
                              child: Align(
                                child: Container(
                                  child: Text(
                                    "Submit",
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

                    ],
                  ),
                ),

                SizedBox(
                  height:60,
                ),


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
                        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()));
                      },
                      child: Column(
                        children: [
                          Icon(Icons.home, color: Colors.grey,),
                          SizedBox(
                            height: 4,
                          ),
                          Text('Home', style: TextStyle(color: Colors.grey, fontSize: 12),),
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
                        /*Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => PayDuesScreen()));
                      */},
                      child: Column(
                        children: [
                          Icon(Icons.phone_android, color: odaSecondary,),
                          SizedBox(
                            height: 4,
                          ),
                          Text('Pay Dues', style: TextStyle(color: odaSecondary, fontSize: 12)),
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
    );
  }


  void _payDuesModal (BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: odaPrimary,
                    borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.0),
                        topLeft: Radius.circular(20.0)
                    )
                ),
                height: 300,
              ),
              Positioned(
                top: 15,
                child: Container(
                  height: 250,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20.0),
                          topLeft: Radius.circular(20.0)
                      )
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.05)
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Pay Dues", style: TextStyle(color: Colors.black, fontSize: 20),),
                          ],
                        ),
                      ),

                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(30),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,

                          children: [
                            Expanded(child: Text("This feature will be available soon", textAlign: TextAlign.center,style: TextStyle(fontSize: 28),))
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
