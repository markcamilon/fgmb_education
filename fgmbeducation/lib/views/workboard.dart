import 'dart:convert';
import 'package:workistant/components/notFound.dart';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/models/workBoardInfo.model.dart';
import 'package:workistant/models/workCard.model.dart';
import 'package:workistant/models/workList.model.dart';
import 'package:workistant/views/MainTabLayout.dart';
import 'package:workistant/views/workhistory.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class WorkBoardScreen extends StatefulWidget {
  final id;
  WorkBoardScreen({
    this.id,
  });
  @override
  _WorkBoardScreenState createState() => _WorkBoardScreenState();
}

class _WorkBoardScreenState extends State<WorkBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _listAdderKey = GlobalKey<FormState>();
  final _cardAdderKey = GlobalKey<FormState>();
  var _listTitle;
  var _cardContent;
  var fineBoardData;
  var api;
  var displayName;
  var _listEditedTitle;
  var _cardEditedTitle;

  @override
  void initState() {
    super.initState();
    _updateBoardInfo();
  }

  _editCard(cardIndex, listIndex) async {
    setState(() {
      fineBoardData.lists[listIndex].cards[cardIndex].content =
          _cardEditedTitle;
    });
    var response = await http.post(
      Uri.parse(APIRoutes.editWorkCard),
      body: {
        "api": api,
        "content": _cardEditedTitle,
        "cardID": fineBoardData.lists[listIndex].cards[cardIndex].id.toString(),
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Error editing list information. Please try again later.",
          3,
          Colors.deepOrange,
        );
      }
    } else {
      displaySnackBar(
        "Error editing list information. Please try again later.",
        3,
        Colors.deepOrange,
      );
    }
  }

  _editList(index) async {
    if (_listEditedTitle != fineBoardData.lists[index].title) {
      setState(() {
        fineBoardData.lists[index].title = _listEditedTitle;
      });
      var response = await http.post(
        Uri.parse(APIRoutes.editWorkList),
        body: {
          "api": api,
          "listID": fineBoardData.lists[index].id.toString(),
          "title": _listEditedTitle,
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse == "error") {
          displaySnackBar(
            "Error editing list information. Please try again later.",
            3,
            Colors.deepOrange,
          );
        }
      } else {
        displaySnackBar(
          "Error editing list information. Please try again later.",
          3,
          Colors.deepOrange,
        );
      }
    }
  }

  _warnBoardDeletion(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.backgroundColor,
          title: Text(
            AppLocalizations.of(context)!.delete_board,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Text(
            AppLocalizations.of(context)!.sure_delete,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: [
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: _deleteBoard,
              child: Text(
                AppLocalizations.of(context)!.yes,
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.no,
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  _deleteBoard() async {
    var response = await http.post(Uri.parse(APIRoutes.deleteWorkBoard), body: {
      "api": api,
      "boardID": fineBoardData.info.id.toString(),
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Error deleting board information. Please try again later.",
          3,
          Colors.deepOrange,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainTabLayout(
              index: 1,
            ),
          ),
        );
      }
    } else {
      displaySnackBar(
        "Error deleting board information. Please try again later.",
        3,
        Colors.deepOrange,
      );
    }
  }

  _deleteCard(listIndex, cardIndex) async {
    var cardID = fineBoardData.lists[listIndex].cards[cardIndex].id;
    print("cardID: $cardID");
    var response = await http.post(
      Uri.parse(APIRoutes.deleteWorkCard),
      body: {
        "api": api,
        "cardID": cardID.toString(),
      },
    );
    var historyLog =
        "\"${fineBoardData.lists[listIndex].cards[cardIndex].content}\" was deleted from \"${fineBoardData.lists[listIndex].title}\" by $displayName";
    _addHistoryTile(historyLog);
    setState(() {
      fineBoardData.lists[listIndex].cards.removeAt(cardIndex);
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Error deleting list information. Please try again later.",
          3,
          Colors.deepOrange,
        );
      }
    } else {
      displaySnackBar(
        "Error deleting list information. Please try again later.",
        3,
        Colors.deepOrange,
      );
    }
  }

  _deleteList(index) async {
    var response = await http.post(
      Uri.parse(APIRoutes.deleteWorkList),
      body: {
        "api": api,
        "listID": fineBoardData.lists[index].id.toString(),
      },
    );
    var historyLog =
        "\"${fineBoardData.lists[index].title}\" was deleted from \"${fineBoardData.info.title}\" by $displayName";
    _addHistoryTile(historyLog);
    setState(() {
      fineBoardData.lists.removeAt(index);
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Error deleting list information. Please try again later.",
          3,
          Colors.deepOrange,
        );
      }
    } else {
      displaySnackBar(
        "Error deleting list information. Please try again later.",
        3,
        Colors.deepOrange,
      );
    }
  }

  _openListNameEditor(index, context) {
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
            "Edit List",
            style: TextStyle(color: Colors.white),
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _listAdderKey,
                    child: TextFormField(
                      initialValue: _listEditedTitle,
                      onChanged: (value) {
                        setState(() {
                          _listEditedTitle = value;
                        });
                      },
                      // ignore: missing_return
                      validator: (val) {
                        if (val!.length > 12) {
                          return "Too Long (12 chars max)";
                        }
                        if (val.length < 1) {
                          return "Too short (atleast 1 character1)";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'List Title',
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
                    final isValid = _listAdderKey.currentState!.validate();
                    if (isValid) {
                      Navigator.pop(context);
                      _editList(index);
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
                        AppLocalizations.of(context)!.add_list,
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

  _openCardContentEditor(listIndex, cardIndex, context) {
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
            AppLocalizations.of(context)!.edit_title,
            style: TextStyle(color: Colors.white),
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _listAdderKey,
                    child: TextFormField(
                      maxLines: 5,
                      initialValue: _cardEditedTitle,
                      onChanged: (value) {
                        setState(() {
                          _cardEditedTitle = value;
                        });
                      },
                      // ignore: missing_return
                      validator: (val) {
                        if (val!.length < 1) {
                          return "Too short (atleast 1 character1)";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Card Content',
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
                    final isValid = _listAdderKey.currentState!.validate();
                    if (isValid) {
                      Navigator.pop(context);
                      _editCard(cardIndex, listIndex);
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
                        "Save",
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

  _openListOptions(index, context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Constants.backgroundColor,
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 25,
                ),
                title: Text(
                  AppLocalizations.of(context)!.edit_title,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _listEditedTitle = fineBoardData.lists[index].title;
                  });
                  _openListNameEditor(index, context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Colors.deepOrange,
                  size: 25,
                ),
                title: Text(
                  AppLocalizations.of(context)!.delete_list,
                  style: TextStyle(color: Colors.deepOrange, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteList(index);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _openCardOptions(listIndex, cardIndex, context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Constants.backgroundColor,
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.add_road_rounded,
                  color: Colors.white,
                  size: 25,
                ),
                title: Text(
                  AppLocalizations.of(context)!.edit_title,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _cardEditedTitle =
                        fineBoardData.lists[listIndex].cards[cardIndex].content;
                  });
                  _openCardContentEditor(listIndex, cardIndex, context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Colors.deepOrange,
                  size: 25,
                ),
                title: Text(
                  AppLocalizations.of(context)!.delete_list,
                  style: TextStyle(color: Colors.deepOrange, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteCard(listIndex, cardIndex);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _updateBoardInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiKey = prefs.getString("api");
    var _displayName = prefs.getString("display_name");
    setState(() {
      api = apiKey;
      displayName = _displayName;
    });
    var response =
        await http.post(Uri.parse(APIRoutes.getFullBoardInfo), body: {
      "api": api,
      "boardId": widget.id,
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          AppLocalizations.of(context)!.error_occured,
          3,
          Colors.deepOrange,
        );
      } else {
        print(jsonResponse);
        setState(() {
          fineBoardData = new WorkBoardInfo.fromJson(jsonResponse);
        });
      }
    } else {
      displaySnackBar(
        AppLocalizations.of(context)!.error_occured,
        3,
        Colors.deepOrange,
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

  _buildOuterList(WorkList wL, int index) {
    return DragAndDropList(
      contentsWhenEmpty: Text(
        AppLocalizations.of(context)!.no_cards,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      header: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(7.0)),
                gradient: LinearGradient(
                  colors: [
                    Constants.primaryColor,
                    Constants.secondaryColor,
                  ],
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      wL.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.more_horiz,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _openListOptions(index, context);
                      },
                    ),
                  ),
                  Divider(
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      footer: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            _openCardAdder(context, index);
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(
                Icons.add_circle,
                color: Colors.white,
              ),
              title: Text(
                AppLocalizations.of(context)!.add_card,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      leftSide: VerticalDivider(
        color: Colors.transparent,
        width: 1.5,
        thickness: 1.5,
      ),
      children: List.generate(
        wL.cards.length,
        (cardIndex) => _buildInnerList(
          wL.cards[cardIndex],
          cardIndex,
          index,
        ),
      ),
    );
  }

  _buildInnerList(WorkCard wC, cardIndex, listIndex) {
    return DragAndDropItem(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Constants.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            title: Text(
              wC.content,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.more_horiz,
                color: Colors.white,
              ),
              onPressed: () {
                _openCardOptions(listIndex, cardIndex, context);
              },
            ),
          ),
        ),
      ),
    );
  }

  _openListAdder(BuildContext context) {
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
            AppLocalizations.of(context)!.add_list,
            style: TextStyle(color: Colors.white),
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _listAdderKey,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _listTitle = value;
                        });
                      },
                      // ignore: missing_return
                      validator: (val) {
                        if (val!.length > 12) {
                          return "Too Long (12 chars max)";
                        }
                        if (val.length < 1) {
                          return "Too short (atleast 1 character1)";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'List Title',
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
                    final isValid = _listAdderKey.currentState!.validate();
                    if (isValid) {
                      Navigator.pop(context);
                      _addList();
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
                        "Add List",
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

  _openCardAdder(BuildContext context, index) {
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
            AppLocalizations.of(context)!.add_card,
            style: TextStyle(color: Colors.white),
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _cardAdderKey,
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _cardContent = value;
                        });
                      },
                      // ignore: missing_return
                      validator: (val) {
                        if (val!.length < 1) {
                          return "Too short (atleast 1 character1)";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Card Content',
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
                    final isValid = _cardAdderKey.currentState!.validate();
                    if (isValid) {
                      Navigator.pop(context);
                      _addCard(index);
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
                        AppLocalizations.of(context)!.add_card,
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

  _addCard(listIndex) async {
    var newCardPosition = fineBoardData.lists[listIndex].cards == []
        ? "0"
        : fineBoardData.lists[listIndex].cards.length;
    var listID = fineBoardData.lists[listIndex].id;
    var boardID = fineBoardData.info.id;
    var response = await http.post(Uri.parse(APIRoutes.addWorkCard), body: {
      "api": api,
      "posIndex": newCardPosition.toString(),
      "listID": listID.toString(),
      "boardID": boardID.toString(),
      "content": _cardContent.toString(),
      "by": displayName.toString(),
    });
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "success") {
        var historyLog =
            "$displayName added \"$_cardContent\" to \"${fineBoardData.lists[listIndex].title}\" ";
        _addHistoryTile(historyLog);
        _updateBoardInfo();
      } else {
        displaySnackBar(
          "Request timed out. Please try again later.",
          2,
          Colors.red,
        );
      }
    } else {
      displaySnackBar(
        "Request timed out. Please try again later.",
        2,
        Colors.red,
      );
    }
  }

  _showBoardOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Constants.backgroundColor,
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.history_edu,
                  color: Colors.white,
                  size: 25,
                ),
                title: Text(
                  AppLocalizations.of(context)!.board_history,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkHistoryScreen(
                        boardID: fineBoardData.info.id,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.add_road_rounded,
                  color: Colors.white,
                  size: 25,
                ),
                title: Text(
                  AppLocalizations.of(context)!.add_list,
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openListAdder(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Colors.deepOrange,
                  size: 25,
                ),
                title: Text(
                  AppLocalizations.of(context)!.delete_board,
                  style: TextStyle(color: Colors.deepOrange, fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _warnBoardDeletion(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  _addList() async {
    var posIndex =
        fineBoardData.lists == [] ? "0" : fineBoardData.lists.length.toString();
    var boardID = fineBoardData.info.id;
    var response = await http.post(
      Uri.parse(APIRoutes.addWorkList),
      body: {
        "api": api,
        "posIndex": posIndex,
        "boardID": boardID,
        "title": _listTitle,
        "by": displayName,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "success") {
        displaySnackBar(
          "List successfully added.",
          2,
          Colors.green,
        );
        var historyLog = "$_listTitle was added by $displayName";
        _addHistoryTile(historyLog);
        _updateBoardInfo();
      } else {
        displaySnackBar(
          "Request timed out. Please try again later.",
          2,
          Colors.red,
        );
      }
    } else {
      displaySnackBar(
        "Request timed out. Please try again later.",
        2,
        Colors.red,
      );
    }
  }

  _addHistoryTile(content) async {
    var response = await http.post(
      Uri.parse(APIRoutes.createHistoryLog),
      body: {
        "api": api,
        "content": content,
        "boardID": fineBoardData.info.id,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Request timed out. Please try again later.",
          2,
          Colors.red,
        );
      }
    } else {
      displaySnackBar(
        "Request timed out. Please try again later.",
        2,
        Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainTabLayout(index: 1),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showBoardOptions(context);
            },
            icon: Icon(
              Icons.more_vert_rounded,
            ),
          ),
        ],
        backgroundColor: Constants.backgroundColor,
        elevation: 0,
        title: fineBoardData == null
            ? Text("...")
            : Text(fineBoardData.info.title),
      ),
      body: fineBoardData == null
          ? Center(
              child: LoadingBouncingGrid.square(
                backgroundColor: Constants.primaryColor,
                borderColor: Constants.primaryColor,
              ),
            )
          : DragAndDropLists(
              contentsWhenEmpty: Column(
                children: [
                  NotFoundWidget(key: ValueKey("")),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      _openListAdder(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Constants.primaryColor,
                            Constants.secondaryColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          AppLocalizations.of(context)!.add_list,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              children: List.generate(
                fineBoardData.lists.length,
                (index) => _buildOuterList(
                  fineBoardData.lists[index],
                  index,
                ),
              ),
              onItemReorder: _onItemReorder,
              onListReorder: _onListReorder,
              axis: Axis.horizontal,
              listWidth: 250,
              listDraggingWidth: 250,
              listDecoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Constants.primaryColor,
                    Constants.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black45,
                    spreadRadius: 3.0,
                    blurRadius: 6.0,
                    offset: Offset(2, 3),
                  ),
                ],
              ),
              listPadding: EdgeInsets.all(8.0),
            ),
    );
  }

  _onItemReorder(int oldItemIndex, int oldListIndex, int newItemIndex,
      int newListIndex) async {
    var toUpdateItem;
    setState(() {
      var movedCard =
          fineBoardData.lists[oldListIndex].cards.removeAt(oldItemIndex);
      fineBoardData.lists[newListIndex].cards.insert(newItemIndex, movedCard);
      toUpdateItem = movedCard;
    });
    var newListID = fineBoardData.lists[newListIndex].id;
    var oldListID = fineBoardData.lists[oldListIndex].id;
    var cardID = toUpdateItem.id;
    var response = await http.post(
      Uri.parse(APIRoutes.changeCardPosition),
      body: {
        "api": api,
        "posIndex": newItemIndex.toString(),
        "listID": newListID,
        "cardID": cardID,
        "oldList": oldListID,
        "oldPos": oldItemIndex.toString(),
      },
    );
    if (oldListIndex != newListIndex) {
      var historyLog =
          "\"${toUpdateItem.content}\" was moved from \"${fineBoardData.lists[oldListIndex].title}\" to \"${fineBoardData.lists[newListIndex].title}\" by $displayName";
      _addHistoryTile(historyLog);
    }
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Changes couldn't be saved due to connection problem.",
          3,
          Colors.red,
        );
      }
    } else {
      displaySnackBar(
        "Changes couldn't be saved due to connection problem.",
        3,
        Colors.red,
      );
    }
  }

  _onListReorder(int oldListIndex, int newListIndex) async {
    var toUpdateList;
    setState(() {
      var movedList = fineBoardData.lists.removeAt(oldListIndex);
      fineBoardData.lists.insert(newListIndex, movedList);
      toUpdateList = movedList;
    });
    var response = await http.post(
      Uri.parse(APIRoutes.changeListPosition),
      body: {
        "api": api,
        "posIndex": newListIndex.toString(),
        "listID": toUpdateList.id.toString(),
        "boardID": fineBoardData.info.id,
        "oldPos": oldListIndex.toString(),
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "Changes couldn't be saved due to connection problem.",
          3,
          Colors.red,
        );
      }
    } else {
      displaySnackBar(
        "Changes couldn't be saved due to connection problem.",
        3,
        Colors.red,
      );
    }
  }
}
