import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:odadee/Screens/Articles/models/comment_model.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/fund_for_screen.dart';
import 'package:odadee/Screens/Projects/models/project_detail_model.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Radio/radio_screen.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/constants.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Radio/playing_screen.dart';
import 'package:http/http.dart' as http;


Future<CommentModel> getAllComments(comment_id) async {

  var token = await getApiPref();

  final response = await http.get(
    Uri.parse(hostName + "/api/comments/" + comment_id.toString()),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + token.toString()
    },

  );

  if (response.statusCode == 200) {
    print(jsonDecode(response.body));

    return CommentModel.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 422) {
    print(jsonDecode(response.body));
    return CommentModel.fromJson(jsonDecode(response.body));
  }  else {

    throw Exception('Failed to load data');
  }
}

class NewsDetailsScreen extends StatefulWidget {
  final data;

  const NewsDetailsScreen({Key? key, required this.data}) : super(key: key);

  @override
  State<NewsDetailsScreen> createState() => _NewsDetailsScreenState();
}

class _NewsDetailsScreenState extends State<NewsDetailsScreen> {

  final _formKey = GlobalKey<FormState>();
  Future<CommentModel>? _futureGetAllComments;
  final commentController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _futureGetAllComments = getAllComments(widget.data.id.toString());

  }

  @override
  Widget build(BuildContext context) {
    return (_futureGetAllComments == null) ? buildColumn() : buildFutureBuilder();

  }

  buildColumn(){
    return Scaffold(
      body: SafeArea(
        child: Container(),
      ),
    );
  }




  FutureBuilder<CommentModel> buildFutureBuilder() {
    return FutureBuilder<CommentModel>(
        future: _futureGetAllComments,
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
          }
          else if(snapshot.hasData) {

            var data = snapshot.data!;
            var comments = data.comments!.data!;

            print("#########################");

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
                                    Text("News Detail", style: TextStyle(fontSize: 20, color: Colors.black),),
                                  ],
                                ),
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
                              child: SingleChildScrollView(
                                child: Container(
                                  //height: MediaQuery.of(context).size.height,
                                  margin: EdgeInsets.all(15),
                                  child:Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(20),

                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,

                                          children: [
                                            Container(
                                              height: 169,
                                              decoration: BoxDecoration(
                                                  color:odaSecondary.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(10),
                                                  image: DecorationImage(
                                                      image: NetworkImage(widget.data.image!.toString()),
                                                      fit: BoxFit.cover

                                                  )
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(child: Text(widget.data.title!.toString(), maxLines: 2,overflow: TextOverflow.ellipsis, style: TextStyle( fontSize: 18, color: Colors.black),)),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.access_time_outlined, size: 20, color: Colors.grey,),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(convertToFormattedDate(widget.data.createdTime!.toString()), style: TextStyle( fontSize: 12, color:Colors.grey),),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.person_outlined, size: 20, color: Colors.grey,),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text("By Jones", style: TextStyle( fontSize: 12, color:Colors.grey),),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 10,
                                            ),

                                            Html(
                                              data: widget.data.content!.toString(),
                                            ),

                                            SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 20,
                                                  ),
                                                  Text("Share this News"),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Image(image: AssetImage("assets/images/facebookl.png",), height: 40,),
                                                      SizedBox(
                                                        width: 5,
                                                      ),

                                                      Image(image: AssetImage("assets/images/twiterl.png",), height: 40,),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Image(image: AssetImage("assets/images/insta.png",), height: 40,)
                                                    ],
                                                  )

                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),

                                            GradientText(
                                                'Add Comment',
                                                style: const TextStyle(fontSize: 12, color: odaSecondary),
                                                colors: [
                                                  odaPrimary,
                                                  odaSecondary,
                                                ]
                                            ),
                                            SizedBox(
                                              height: 10,
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
                                                controller: commentController,
                                                maxLines: 4,
                                                decoration: InputDecoration(
                                                  //hintText: 'Enter Username/Email',



                                                  hintStyle: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight: FontWeight.normal),
                                                  labelText: "Comment",
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

                                                textInputAction: TextInputAction.next,
                                                autofocus: false,
                                                onSaved: (value) {
                                                  setState(() {

                                                    //added_comment = value;

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
                                                    String commentText = commentController.text;
                                                    if (commentText.isNotEmpty) {
                                                      // Post the comment
                                                      postComment(commentText);
                                                      // Clear the input field
                                                      commentController.clear();
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: odaSecondary.withOpacity(0.3),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text("Add Comment", style: TextStyle(fontSize: 10)),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(
                                              height: 20,
                                            ),
                                            GradientText(
                                                'Comments',
                                                style: const TextStyle(fontSize: 12, color: odaSecondary),
                                                colors: [
                                                  odaPrimary,
                                                  odaSecondary,
                                                ]
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),

                                            Container(
                                              height: 350,
                                              child:       ListView.builder(
                                                  //shrinkWrap: true,

                                                 itemCount: comments.length,

                                                  itemBuilder: (context, index) {
                                                   var comment = comments[index];

                                                    return   Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              height: 50,
                                                              width: 50,
                                                              decoration: BoxDecoration(
                                                                  //color: odaSecondary.withOpacity(0.1),
                                                                  borderRadius: BorderRadius.circular(5),
                                                                  image: DecorationImage(
                                                                      image: AssetImage("assets/images/Default_pfp.svg.png"),
                                                                      fit: BoxFit.cover
                                                                  )

                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(comment.author.toString(), style: TextStyle(fontSize: 16, color: Colors.black),),
                                                                  SizedBox(
                                                                    height: 5,
                                                                  ),
                                                                  Text(comment.createdTime.toString(), style: TextStyle(fontSize: 14, color: Colors.grey),),
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
                                                                  Text(comment.content.toString(), style: TextStyle(fontSize: 14, color: Colors.grey),),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),


                                                        SizedBox(
                                                          height: 30,
                                                        ),
                                                      ],
                                                    );
                                                  }
                                              ),
                                            ),


                                            SizedBox(
                                              height: 50,
                                            ),






                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
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


        }
    );
  }




  Future<void> postComment(String commentText) async {
    var token = await getApiPref();

    final response = await http.post(
      Uri.parse(hostName + "/api/comments"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer ' + token.toString(),
      },
      body: jsonEncode({
        "comment": commentText,
        "articleId": widget.data.id, // Assuming this is how you associate comments with articles
      }),
    );

    if (response.statusCode == 200) {
      // Comment added successfully
      // Trigger a reload of comments
      setState(() {
        _futureGetAllComments = getAllComments(widget.data.id.toString());
      });
    } else {
      // Handle error
      print("Failed to add a comment");
    }
  }




}
