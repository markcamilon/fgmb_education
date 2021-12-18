import 'dart:convert';

import 'package:workistant/components/boardTile.dart';
import 'package:workistant/components/notFound.dart';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/models/workBoard.model.dart';
import 'package:workistant/views/workboard.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class WorkScreen extends StatefulWidget {
  var workBoards;
  WorkScreen({this.workBoards});
  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _adderKey = GlobalKey<FormState>();
  String _boardTitle = "";

  @override
  void initState() {
    super.initState();
    _getWorkBoards();
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
        widget.workBoards =
            jsonResponse.map((board) => new WorkBoard.fromJson(board)).toList();
      });
      if (widget.workBoards.length < 1) {
        setState(() {
          widget.workBoards = "empty";
        });
      }
    } else {
      setState(() {
        widget.workBoards = "empty";
      });
    }
  }

  ListView _boardsListView(data) {
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
                builder: (_) => WorkBoardScreen(
                  id: data[index].id,
                ),
              ),
            );
          },
          child: BoardTile(
            title: data[index].title,
            type: data[index].shared != "0"
                ? "Shared"
                : AppLocalizations.of(context)!.personal,
          ),
        );
      },
    );
  }

  _buildBoardsList() {
    if (widget.workBoards == "empty") {
      return NotFoundWidget(key: ValueKey(""));
    } else {
      return widget.workBoards != null
          ? _boardsListView(widget.workBoards)
          : Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Constants.primaryColor,
                borderColor: Constants.primaryColor,
              ),
            );
    }
  }

  _showAddDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          backgroundColor: Constants.backgroundColor,
          title: Text(
            AppLocalizations.of(context)!.work_boards,
            style: TextStyle(color: Colors.white),
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _adderKey,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _boardTitle = value;
                        });
                      },
                      // ignore: missing_return
                      validator: (val) {
                        if (val!.length > 12) {
                          return "Too Long (12 chars max)";
                        }
                        if (val.length < 3) {
                          return "Too short (atleast 3 characters)";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.title,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withAlpha(210),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide(
                            width: 0,
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.all(16),
                        fillColor: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    final isValid = _adderKey.currentState!.validate();
                    if (isValid) {
                      Navigator.pop(context);
                      _addBoard();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [
                          Constants.primaryColor,
                          Constants.secondaryColor,
                        ],
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        AppLocalizations.of(context)!.add_board,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _addBoard() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _api = prefs.getString("api");
    var response = await http.post(
      Uri.parse(APIRoutes.addWorkBoard),
      body: {
        "api": _api,
        "title": _boardTitle,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          AppLocalizations.of(context)!.error_occured,
          2,
          Colors.red,
        );
      } else if (jsonResponse == "error") {
        displaySnackBar(
          "ACCESS DENIED. ILLEGAL ACCESS REQUESTED.",
          2,
          Colors.red,
        );
      } else {
        displaySnackBar(
          "Board Added.",
          2,
          Colors.green,
        );
        _getWorkBoards();
      }
    } else {
      displaySnackBar(
        AppLocalizations.of(context)!.error_occured,
        2,
        Colors.red,
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
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              AppLocalizations.of(context)!.work_boards,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacer(),
            GestureDetector(
              onTap: () {
                _showAddDialog(context);
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
          ],
        ),
        elevation: 0,
        backgroundColor: Constants.backgroundColor,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildBoardsList(),
            ],
          ),
        ),
      ),
    );
  }
}
