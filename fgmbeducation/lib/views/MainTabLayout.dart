import 'dart:convert';

import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/models/financeBoard.model.dart';
import 'package:workistant/models/reminderPallette.model.dart';
import 'package:workistant/models/workBoard.model.dart';
import 'package:workistant/views/dashboard.dart';
import 'package:workistant/views/finance.dart';
import 'package:workistant/views/reminders.dart';
import 'package:workistant/views/settings.dart';
import 'package:workistant/views/work.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MainTabLayout extends StatefulWidget {
  final int index;

  MainTabLayout({required this.index});

  @override
  _MainTabLayoutState createState() => _MainTabLayoutState();
}

class _MainTabLayoutState extends State<MainTabLayout> {
  var workBoards;
  var financeBoards;
  var reminders;

  @override
  void initState() {
    super.initState();
    _getWorkBoards();
    _getFinanceBoards();
    _getReminders();
  }

  _getWorkBoards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api = prefs.getString("api");
    print("processing");
    var response = await http.post(
      Uri.parse(APIRoutes.getWorkBoards),
      body: {
        "api": api,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        workBoards =
            jsonResponse.map((board) => new WorkBoard.fromJson(board)).toList();
      });
      if (workBoards.length < 1) {
        setState(() {
          workBoards = "empty";
        });
      }
    } else {
      setState(() {
        workBoards = "empty";
      });
    }
  }

  _getFinanceBoards() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var api = prefs.getString("api");
    print("processing");
    var response = await http.post(
      Uri.parse(APIRoutes.getFinanceBoards),
      body: {
        "api": api,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      setState(() {
        financeBoards = jsonResponse
            .map((board) => new FinanceBoard.fromJson(board))
            .toList();
      });
      if (financeBoards.length < 1) {
        setState(() {
          financeBoards = "empty";
        });
      }
    } else {
      setState(() {
        financeBoards = "empty";
      });
    }
  }

  _getReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiKey = prefs.getString("api");
    var response = await http.post(
      Uri.parse(APIRoutes.getReminders),
      body: {
        "api": apiKey,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        setState(() {
          reminders = "empty";
        });
      } else {
        setState(() {
          reminders = jsonResponse
              .map((pallette) => new ReminderPalletteData.fromJson(pallette))
              .toList();
        });
        if (reminders.length < 1) {
          setState(() {
            reminders = "empty";
          });
        }
      }
    } else {
      setState(() {
        reminders = "empty";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: widget.index,
      length: 5,
      child: Scaffold(
        backgroundColor: Constants.backgroundColor,
        bottomNavigationBar: TabBar(
          unselectedLabelColor: Colors.grey,
          indicatorPadding: EdgeInsets.all(0.0),
          indicatorWeight: 4.0,
          labelPadding: EdgeInsets.only(left: 0.0, right: 0.0),
          indicator: ShapeDecoration(
            shape: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 4.0,
                style: BorderStyle.solid,
              ),
            ),
            gradient: LinearGradient(
              colors: [
                Constants.primaryColor,
                Constants.secondaryColor,
              ],
            ),
          ),
          tabs: [
            Tab(
              icon: Icon(
                Icons.dashboard_outlined,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.work,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.attach_money,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.date_range_outlined,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.settings,
              ),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            DashboardScreen(),
            WorkScreen(
              workBoards: workBoards,
            ),
            FinanceMenu(
              financeBoards: financeBoards,
            ),
            RemindersMenu(
              reminders: reminders,
            ),
            SettingsMenu()
          ],
        ),
      ),
    );
  }
}
