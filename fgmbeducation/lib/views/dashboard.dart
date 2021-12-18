import 'dart:convert';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/models/reminderPallette.model.dart';
import 'package:workistant/views/MainTabLayout.dart';
import 'package:workistant/views/welcome.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var finalDate;
  var dayToday;
  var username;
  var apiKey;
  var forTodayReminders;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _confirmLogout(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          backgroundColor: Constants.backgroundColor,
          title: Text(
            AppLocalizations.of(context)!.logout,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            AppLocalizations.of(context)!.sure_logout,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: () {
                _logout(context);
              },
              child: Text(
                AppLocalizations.of(context)!.yes,
                style: TextStyle(color: Colors.green),
              ),
            ),
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.no,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  _logout(ctx) async {
    Navigator.pop(ctx);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(),
      ),
    );
  }

  _loadData() async {
    var date = new DateTime.now().toString();

    var dateParse = DateTime.parse(date);

    var weekDay = _determineWeekDay(dateParse.weekday);
    setState(() {
      dayToday = weekDay;
    });
    var month = _determineMonth(dateParse.month);

    var formattedDate = "$weekDay, $month ${dateParse.day}, ${dateParse.year}";

    setState(() {
      finalDate = formattedDate.toString();
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var dispName = prefs.getString("display_name");
    var api = prefs.getString("api");
    setState(() {
      username = (dispName! + ".");
      apiKey = api;
    });
    _getForTodayList();
  }

  String _determineWeekDay(weekday) {
    if (weekday == 1) {
      return "Monday";
    } else if (weekday == 2) {
      return "Tuesday";
    } else if (weekday == 3) {
      return "Wednesday";
    } else if (weekday == 4) {
      return "Thursday";
    } else if (weekday == 5) {
      return "Friday";
    } else if (weekday == 6) {
      return "Saturday";
    } else if (weekday == 7) {
      return "Sunday";
    }
    return "Today";
  }

  String _determineMonth(month) {
    if (month == 1) {
      return "January";
    } else if (month == 2) {
      return "February";
    } else if (month == 3) {
      return "March";
    } else if (month == 4) {
      return "April";
    } else if (month == 5) {
      return "May";
    } else if (month == 6) {
      return "June";
    } else if (month == 7) {
      return "July";
    } else if (month == 8) {
      return "August";
    } else if (month == 9) {
      return "September";
    } else if (month == 10) {
      return "October";
    } else if (month == 11) {
      return "November";
    } else if (month == 12) {
      return "December";
    }
    return "month";
  }

  _getForTodayList() async {
    print(finalDate);
    print(dayToday);
    var response = await http.post(
      Uri.parse(APIRoutes.getTodayReminders),
      body: {
        "api": apiKey,
        "today": finalDate,
        "dayToday": dayToday,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print(jsonResponse);
      if (jsonResponse == "error" || jsonResponse == "empty") {
        setState(() {
          forTodayReminders = "empty";
        });
      } else {
        setState(() {
          forTodayReminders = jsonResponse
              .map((reminder) => new ReminderPalletteData.fromJson(reminder))
              .toList();
        });
        print(jsonResponse);
      }
    } else {
      setState(() {
        forTodayReminders = "empty";
      });
    }
  }

  ListView _forTodayListView(data) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainTabLayout(
                  index: 3,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.purpleAccent,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 7,
                ),
                child: ListTile(
                  leading: Text(
                    data[index].time,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    data[index].message,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              width: MediaQuery.of(context).size.width,
            ),
          ),
        );
      },
    );
  }

  _buildForTodayList() {
    if (forTodayReminders == "empty") {
      return Text(
        "Woo Hoo! No tasks for today.",
        style: TextStyle(
          color: Colors.white,
        ),
      );
    } else {
      return forTodayReminders != null
          ? _forTodayListView(
              forTodayReminders,
            )
          : Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Constants.secondaryColor,
                borderColor: Constants.secondaryColor,
              ),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.dashboard,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  _confirmLogout(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      colors: [
                        Colors.red,
                        Colors.deepOrangeAccent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.power_settings_new,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image(
                          image: AssetImage("assets/images/dashboard.png"),
                          height: 200,
                          width: 200,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                child: Text(
                                  AppLocalizations.of(context)!.welcome,
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              Text(
                                username != null ? username : "...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4),
                      ],
                    ),
                    Text(
                      finalDate != null ? finalDate : "...",
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    _buildForTodayList(),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
