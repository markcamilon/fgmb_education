import 'dart:convert';
import 'package:workistant/models/financeBoard.model.dart';
import 'package:workistant/views/financeboard.dart';
import 'package:http/http.dart' as http;
import 'package:workistant/components/boardTile.dart';
import 'package:workistant/components/notFound.dart';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ignore: must_be_immutable
class FinanceMenu extends StatefulWidget {
  var financeBoards;
  FinanceMenu({this.financeBoards});
  @override
  _FinanceMenuState createState() => _FinanceMenuState();
}

class _FinanceMenuState extends State<FinanceMenu> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _adderKey = GlobalKey<FormState>();
  String _boardTitle = "";
  String _boardBudget = "";

  @override
  void initState() {
    super.initState();
    _getFinanceBoards();
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
                builder: (_) => FinanceBoardScreen(
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
    if (widget.financeBoards == "empty") {
      return NotFoundWidget(
        key: ValueKey(""),
      );
    } else {
      return widget.financeBoards != null
          ? _boardsListView(
              widget.financeBoards,
            )
          : Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Constants.secondaryColor,
                borderColor: Constants.secondaryColor,
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
            AppLocalizations.of(context)!.finance_boards,
            style: TextStyle(color: Colors.white),
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _adderKey,
                    child: Column(
                      children: [
                        TextFormField(
                          onChanged: (value) {
                            setState(() {
                              _boardTitle = value;
                            });
                          },
                          // ignore: missing_return
                          validator: (val) {
                            if (val!.length > 12) {
                              return "Too Long. (12 characters max)";
                            }
                            if (val.length < 3) {
                              return "Too short. (atleast 3 characters)";
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
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          enableInteractiveSelection: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _boardBudget = value;
                            });
                          },
                          // ignore: missing_return
                          validator: (val) {
                            if (val!.length > 12) {
                              return "Too Long. (12 digit max)";
                            }
                            if (val.length < 1) {
                              return "Too short. (atleast 1 digit)";
                            }
                          },
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.budget,
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
                      ],
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
      Uri.parse(APIRoutes.addFinanceBoard),
      body: {
        "api": _api,
        "title": _boardTitle,
        "budget": _boardBudget,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "There was a problem connecting to the server. Try again later.",
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
        _getFinanceBoards();
      }
    } else {
      displaySnackBar(
        "There was a problem connecting to the server. Try again later.",
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
        widget.financeBoards = jsonResponse
            .map((board) => new FinanceBoard.fromJson(board))
            .toList();
      });
      if (widget.financeBoards.length < 1) {
        setState(() {
          widget.financeBoards = "empty";
        });
      }
    } else {
      setState(() {
        widget.financeBoards = "empty";
      });
    }
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
              AppLocalizations.of(context)!.finance_boards,
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
