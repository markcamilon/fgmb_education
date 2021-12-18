import 'dart:convert';

import 'package:workistant/components/ReminderPalette.dart';
import 'package:workistant/components/notFound.dart';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/models/reminderPallette.model.dart';
import 'package:workistant/views/addreminder.dart';
import 'package:workistant/views/editreminder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class RemindersMenu extends StatefulWidget {
  var reminders;
  RemindersMenu({this.reminders});
  @override
  _RemindersMenuState createState() => _RemindersMenuState();
}

class _RemindersMenuState extends State<RemindersMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getReminders();
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
        displaySnackBar(
          "Connection couldn't be established, Please try again later.",
          3,
          Colors.red,
        );
      } else {
        setState(() {
          widget.reminders = jsonResponse
              .map((pallette) => new ReminderPalletteData.fromJson(pallette))
              .toList();
        });
        if (widget.reminders.length < 1) {
          setState(() {
            widget.reminders = "empty";
          });
        }
      }
    } else {
      setState(() {
        widget.reminders = "empty";
      });
    }
  }

  ListView _remindersListView(data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => EditReminderScreen(
                  reminderData: ReminderPalletteData(
                    id: data[index].id,
                    ownerID: data[index].ownerID,
                    message: data[index].message,
                    time: data[index].time,
                    day: data[index].day,
                    status: data[index].status,
                    type: data[index].type,
                    notificationKey: data[index].notificationKey,
                    createdOn: data[index].createdOn,
                  ),
                ),
              ),
            );
          },
          child: ReminderPallete(
            title: data[index].message,
            time: data[index].time,
            day: data[index].day,
          ),
        );
      },
    );
  }

  _buildRemindersList() {
    if (widget.reminders == "empty") {
      return NotFoundWidget(
        key: ValueKey(""),
      );
    } else {
      return widget.reminders != null
          ? _remindersListView(
              widget.reminders,
            )
          : Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Constants.secondaryColor,
                borderColor: Constants.secondaryColor,
              ),
            );
    }
  }

  void displaySnackBar(String message, int seconds, Color bgColor) {
    // ignore: deprecated_member_use
    _scaffoldKey.currentState!.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: seconds),
        backgroundColor: bgColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.reminders,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReminderAdder(),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      colors: [
                        Constants.primaryColor,
                        Constants.secondaryColor,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Icon(
                      Icons.add_box_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildRemindersList(),
            ),
          ],
        ),
      ),
    );
  }
}
