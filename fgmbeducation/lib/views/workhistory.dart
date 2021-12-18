import 'dart:convert';

import 'package:workistant/components/notFound.dart';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/models/workHistory.model.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkHistoryScreen extends StatefulWidget {
  final boardID;

  WorkHistoryScreen({this.boardID});

  @override
  _WorkHistoryScreenState createState() => _WorkHistoryScreenState();
}

class _WorkHistoryScreenState extends State<WorkHistoryScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var apiKey;
  var workHistory;

  @override
  void initState() {
    super.initState();
    _loadWorkHistory();
  }

  _loadWorkHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var lAPI = prefs.getString("api");
    setState(() {
      apiKey = lAPI;
    });
    var response = await http.post(Uri.parse(APIRoutes.getWorkHistory), body: {
      "api": apiKey,
      "boardID": widget.boardID,
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Failed loading transaction history, please reload to try again.",
          3,
          Colors.red,
        );
      } else if (jsonResponse == "empty") {
        setState(() {
          workHistory = "empty";
        });
      } else {
        setState(() {
          workHistory = jsonResponse
              .map((history) => new WorkHistoryTile.fromJson(history))
              .toList();
        });
        print(jsonResponse);
      }
    } else {
      displaySnackBar(
        "Failed loading transaction history, please reload to try again.",
        3,
        Colors.red,
      );
    }
  }

  _buildWorkList() {
    if (workHistory == "empty") {
      return NotFoundWidget(key: ValueKey(""));
    } else {
      return workHistory != null
          ? _historyListView(
              workHistory,
            )
          : Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Constants.secondaryColor,
                borderColor: Constants.secondaryColor,
              ),
            );
    }
  }

  _historyListView(data) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Constants.primaryColor,
                Constants.secondaryColor,
              ]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                data[index].content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        );
      },
    );
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
      appBar: AppBar(
        backgroundColor: Constants.backgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.board_history,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildWorkList(),
    );
  }
}
