import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:odadee/Screens/AllUsers/models/all_users_model.dart';
import 'package:odadee/Screens/AllUsers/user_detail_screen.dart';
import 'package:odadee/Screens/Profile/user_profile_screen.dart';
import 'package:odadee/Screens/Projects/pay_dues.dart';
import 'package:odadee/Screens/Settings/settings_screen.dart';
import 'package:odadee/components/keyboard_utils.dart';
import 'package:odadee/constants.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

import '../Radio/playing_screen.dart';

class AllRegisteredUsers extends StatefulWidget {
  const AllRegisteredUsers({super.key});

  @override
  _AllRegisteredUsersState createState() => _AllRegisteredUsersState();
}

class _AllRegisteredUsersState extends State<AllRegisteredUsers> {
  List yearGroupList = [];
  int currentPage = 1;
  int lastPage = 1;
  bool isLoading = false;

  bool show_filter = false;
  final _formKey = GlobalKey<FormState>();

  String? _year;
  String _city = "";
  String _house = "";
  String _position = "";

  String? currentFilters;
  int currentFilteredPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Define your initial filter criteria here (e.g., set some default values)
    String? initialYeargroup = '';
    String? initialCity = '';
    String? initialHouse = '';
    String? initialPosition = '';

    // Build the initial filter criteria
    String? initialFilters = buildFilterQueryString(
        initialYeargroup, initialCity, initialHouse, initialPosition);

    // Fetch the filtered data on initialization
    _fetchFilteredData(1, initialFilters);

    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener function
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (currentFilteredPage < lastPage && !isLoading) {
        currentFilteredPage++;
        // Fetch the next page of filtered data using the current filter criteria
        _fetchFilteredData(currentFilteredPage, currentFilters);
      }
    }
  }

// Function to fetch filtered data
  Future<void> _fetchFilteredData(int page, String? filters) async {
    setState(() {
      isLoading = true;
    });

    var token = await getApiPref();

    final uri = Uri.parse(
        '$hostName/api/users?page=$page${filters != null ? '&$filters' : ''}');

    print(uri);

    final response = await http.get(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final eventData = Users.fromJson(data['users']);

      print(data);

      setState(() {
        lastPage = eventData.lastPage!;
        yearGroupList.addAll(eventData.data!);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load filtered data');
    }
  }

// Function to apply filters
  void applyFilters(
      {String? yeargroup, String? city, String? house, String? position}) {
    yearGroupList.clear();
    // Update the filter criteria and reset the page to 1
    currentFilters = buildFilterQueryString(yeargroup, city, house, position);
    currentFilteredPage = 1;

    // Fetch the filtered data with the updated criteria
    _fetchFilteredData(currentFilteredPage, currentFilters);
  }

  String? buildFilterQueryString(
      String? yeargroup, String? city, String? house, String? position) {
    final filters = <String, String?>{
      if (yeargroup != null && yeargroup.isNotEmpty) 'yeargroup': yeargroup,
      if (city != null && city.isNotEmpty) 'city': city,
      if (house != null && house.isNotEmpty) 'house': house,
      if (position != null && position.isNotEmpty) 'position': position,
    };

    // Construct the query string
    final queryParameters = filters.entries
        .where((entry) => entry.value != null)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value!)}')
        .join('&');

    return queryParameters.isNotEmpty ? queryParameters : null;
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
                              "All Registered Users",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            if (show_filter) {
                              setState(() {
                                show_filter = false;
                              });
                            } else {
                              setState(() {
                                show_filter = true;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            decoration: BoxDecoration(
                                color: odaPrimary,
                                borderRadius: BorderRadius.circular(5)),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.filter_list_alt,
                                  size: 15,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  "Filter",
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
                  Expanded(
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            /*Container(
                              height: 50,
                              //color: Colors.red,
                              child: ListView.builder(
                                  itemCount: 1,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index){
                                    return Container(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            margin: EdgeInsets.all(5),

                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("95 Year Group", style: TextStyle(fontSize: 16),),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  width: 17,
                                                  height: 17,
                                                  padding: EdgeInsets.all(1),

                                                  child: Center(child: Text("x", style: TextStyle(color: Colors.white, fontSize: 12),)),
                                                  decoration: BoxDecoration(
                                                      color: odaSecondary.withOpacity(0.3),
                                                      borderRadius: BorderRadius.circular(5)
                                                  ),
                                                ),

                                              ],
                                            ),
                                            decoration: BoxDecoration(
                                                color: odaBorder,
                                                borderRadius: BorderRadius.circular(10)
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                              ),

                            ),*/

                            if (isLoading == true) ...[
                              Expanded(
                                child: Container(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                              ),
                            ] else ...[
                              if (yearGroupList.isNotEmpty) ...[
                                Expanded(
                                  child: Container(
                                    child: ListView.builder(
                                      controller: _scrollController,
                                      itemCount: yearGroupList.length,
                                      itemBuilder: (context, index) {
                                        final userItem = yearGroupList[index];
                                        return InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        UserDetailScreen(
                                                            data: userItem)));
                                          },
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  if (userItem.image != "") ...[
                                                    Container(
                                                      height: 70,
                                                      width: 70,
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color: odaSecondary
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  userItem.image
                                                                      .toString()),
                                                              fit: BoxFit
                                                                  .cover)),
                                                    ),
                                                  ] else ...[
                                                    Container(
                                                      height: 70,
                                                      width: 70,
                                                      margin:
                                                          EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color: odaSecondary
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          image: DecorationImage(
                                                              image: NetworkImage(
                                                                  userItem.image
                                                                      .toString()),
                                                              fit: BoxFit
                                                                  .cover)),
                                                      child: Center(
                                                        child: Text(
                                                          userItem.firstName
                                                                  .toString()
                                                                  .substring(
                                                                      0, 1) +
                                                              userItem.lastName
                                                                  .toString()
                                                                  .substring(
                                                                      0, 1),
                                                          style: TextStyle(
                                                              fontSize: 19,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                  Container(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${userItem.firstName} ${userItem.lastName}",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                        SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          userItem.email
                                                              .toString(),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Text(
                                                          "View Details",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  odaSecondary),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                //width: 150,
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                child: Divider(
                                                  color: Colors.black
                                                      .withOpacity(0.2),
                                                  thickness: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: Container(
                                    child: Center(
                                      child: Text("No users available"),
                                    ),
                                  ),
                                ),
                              ]
                            ]
                          ],
                        ),
                        if (show_filter == true) ...[
                          Stack(
                            children: [
                              Container(
                                height: 530,
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: odaPrimary,
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              Container(
                                height: 520,
                                padding: EdgeInsets.all(20),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GradientText('All Registered Year Groups',
                                        style: const TextStyle(
                                            fontSize: 24, color: odaSecondary),
                                        colors: [
                                          odaPrimary,
                                          odaSecondary,
                                        ]),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Form(
                                              key: _formKey,
                                              child: SingleChildScrollView(
                                                child: Container(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Year Group",
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          GestureDetector(
                                                            onTap: () {
                                                              _showGraduationYearModal(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              height: 60,
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.4))),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    _year ??
                                                                        'Select Year',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        color:
                                                                            bodyText2),
                                                                  ),
                                                                  Icon(
                                                                    Icons
                                                                        .calendar_today_outlined,
                                                                    size: 22,
                                                                    color:
                                                                        odaSecondary,
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
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                                //color: Colors.white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                        child: TextFormField(
                                                          style: TextStyle(),
                                                          decoration:
                                                              InputDecoration(
                                                            //hintText: 'Enter Username/Email',

                                                            hintStyle: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            labelText: "City",
                                                            labelStyle: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    bodyText2),
                                                            enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            focusedBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                                225),
                                                            PasteTextInputFormatter(),
                                                          ],
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          autofocus: false,
                                                          onSaved: (value) {
                                                            setState(() {
                                                              _city = value
                                                                  .toString();
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                                //color: Colors.white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                        child: TextFormField(
                                                          style: TextStyle(),
                                                          decoration:
                                                              InputDecoration(
                                                            //hintText: 'Enter Username/Email',

                                                            hintStyle: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            labelText: "House",
                                                            labelStyle: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    bodyText2),
                                                            enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            focusedBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                                225),
                                                            PasteTextInputFormatter(),
                                                          ],
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          autofocus: false,
                                                          onSaved: (value) {
                                                            setState(() {
                                                              _house = value
                                                                  .toString();
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10),
                                                        decoration:
                                                            BoxDecoration(
                                                                //color: Colors.white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                                border: Border.all(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                        child: TextFormField(
                                                          style: TextStyle(),
                                                          decoration:
                                                              InputDecoration(
                                                            //hintText: 'Enter Username/Email',

                                                            hintStyle: TextStyle(
                                                                color:
                                                                    Colors.grey,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                            labelText:
                                                                "Position",
                                                            labelStyle: TextStyle(
                                                                fontSize: 15,
                                                                color:
                                                                    bodyText2),
                                                            enabledBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            focusedBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.4))),
                                                            border: InputBorder
                                                                .none,
                                                          ),
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(
                                                                225),
                                                            PasteTextInputFormatter(),
                                                          ],
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          autofocus: false,
                                                          onSaved: (value) {
                                                            setState(() {
                                                              _position = value
                                                                  .toString();
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 20,
                                                      ),
                                                      Align(
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .width,
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          decoration: BoxDecoration(
                                                              color:
                                                                  odaSecondary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                          child: Material(
                                                            color: Colors
                                                                .transparent,
                                                            child: InkWell(
                                                              onTap: () {
                                                                if (_formKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  _formKey
                                                                      .currentState!
                                                                      .save();
                                                                  KeyboardUtil
                                                                      .hideKeyboard(
                                                                          context);
                                                                  print(
                                                                      "applyFilters");
                                                                  applyFilters(
                                                                    yeargroup:
                                                                        _year, // You can replace these with the selected filter values
                                                                    city: _city,
                                                                    house:
                                                                        _house,
                                                                    position:
                                                                        _position,
                                                                  );
                                                                }

                                                                //Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => SignUp2()));

                                                                show_filter =
                                                                    false;
                                                              },
                                                              child: Align(
                                                                child:
                                                                    Container(
                                                                  child: Text(
                                                                    "Apply Filter",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            22,
                                                                        color: Colors
                                                                            .white),
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
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        ]
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 75,
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
                        onTap: () {
                          /*      Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => DashboardScreen()));
                      */
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.home,
                              color: odaSecondary,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text(
                              'Home',
                              style:
                                  TextStyle(color: odaSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  RadioScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(Icons.radio, color: Colors.grey),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Radio',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
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
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  UserProfileScreen()));
                        },
                        child: Column(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                            SizedBox(
                              height: 4,
                            ),
                            Text('Profile',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 12)),
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
                              child: ListView.builder(
                                itemCount: 100, // Number of years to display
                                itemBuilder: (BuildContext context, int index) {
                                  final year = 1960 + index;
                                  return InkWell(
                                    onTap: () {
                                      print(year.toString());
                                      setState(() {
                                        _year = year.toString();
                                        Navigator.of(context)
                                            .pop(year.toString());
                                      });
                                    },
                                    child: SizedBox(
                                      height: 50,
                                      child: Column(
                                        children: [
                                          Text(
                                            year.toString(),
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
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
