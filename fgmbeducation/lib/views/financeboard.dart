import 'dart:convert';
import 'dart:math';
import 'package:workistant/components/notFound.dart';
import 'package:workistant/components/transactionTile.dart';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/models/transactionHistory.model.dart';
import 'package:workistant/views/MainTabLayout.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FinanceBoardScreen extends StatefulWidget {
  final id;

  FinanceBoardScreen({
    this.id,
  });

  @override
  _FinanceBoardScreenState createState() => _FinanceBoardScreenState();
}

class _FinanceBoardScreenState extends State<FinanceBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _adderKey = GlobalKey<FormState>();
  String _transactionReason = "";
  String _transactionMoney = "";

  var boardID;
  var boardTitle;
  var boardType;
  var boardBudget = "...";

  var apiKey;
  var email;

  var transactionHistory;

  @override
  void initState() {
    super.initState();
    _getBoardInfo();
    _loadTransactionList();
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
    var response = await http.post(
      Uri.parse(APIRoutes.deleteFinanceBoard),
      body: {
        "api": apiKey,
        "boardID": boardID,
      },
    );
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
              index: 2,
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

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  _makeTransaction(bool isAddition) async {
    var transactionAmount = double.parse(_transactionMoney);
    var currentAmount = double.parse(boardBudget);
    var newAmount = isAddition
        ? roundDouble(currentAmount + transactionAmount, 2)
        : roundDouble(currentAmount - transactionAmount, 2);
    setState(() {
      boardBudget = newAmount.toString();
    });

    print("apiKey: $apiKey");
    print("boardID: $boardID");
    print("_transactionReason: $_transactionReason");
    print("_transactionMoney: $_transactionMoney");
    print("isAddition: ${isAddition ? 1 : 0}");
    print("newBalance: ${newAmount.toString()}");

    var response = await http.post(
      Uri.parse(APIRoutes.makeTransaction),
      body: {
        "api": apiKey,
        "boardID": boardID,
        "reason": _transactionReason,
        "amount": _transactionMoney,
        "isAddition": isAddition ? "1" : "0",
        "by": email,
        "newBalance": newAmount.toString()
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "done") {
        displaySnackBar(
          "Transaction was processed",
          3,
          Colors.green,
        );
        _loadTransactionList();
      } else {
        displaySnackBar(
          "An unknown error occured. Try again later.",
          3,
          Colors.red,
        );
      }
    } else {
      displaySnackBar(
        "There was an error updating the transaction with servers. The transactions might disappear upon reloading. Contact the developers if this issue persists.",
        5,
        Colors.deepOrange,
      );
    }
  }

  _openTransactor(context, bool isAddition) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Constants.backgroundColor,
          child: Column(
            children: [
              SizedBox(
                height: 30,
              ),
              ListTile(
                title: IconButton(
                  icon: Icon(
                    Icons.arrow_circle_down_sharp,
                    color: Colors.white,
                    size: 50,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: ListTile(
                  title: Text(
                    isAddition
                        ? AppLocalizations.of(context)!.add_money
                        : AppLocalizations.of(context)!.deduct_money,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                  trailing: Icon(
                    isAddition ? Icons.add_circle : Icons.remove_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _adderKey,
                  child: Column(
                    children: [
                      TextFormField(
                        enableInteractiveSelection: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _transactionMoney = value;
                          });
                        },
                        // ignore: missing_return
                        validator: (val) {
                          if (val!.length < 1) {
                            return "Too short. (atleast 1 digit)";
                          }
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.amount,
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
                        height: 20,
                      ),
                      TextFormField(
                        onChanged: (value) {
                          setState(
                            () {
                              _transactionReason = value;
                            },
                          );
                        },
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.reason,
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
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  final isValid = _adderKey.currentState!.validate();
                  if (isValid) {
                    Navigator.pop(context);
                    _makeTransaction(isAddition);
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        !isAddition ? Colors.redAccent : Colors.green,
                        !isAddition ? Colors.deepOrange : Colors.lightGreen,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      AppLocalizations.of(context)!.transact,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _getBoardInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var lAPI = prefs.getString("api");
    var lEmail = prefs.getString("email");
    setState(() {
      apiKey = lAPI;
      email = lEmail;
    });
    var response = await http.post(
      Uri.parse(APIRoutes.getFinanceBoard),
      body: {
        "api": apiKey,
        "id": widget.id,
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "none" || jsonResponse == "invalid") {
        displaySnackBar(
          "An error occured while loading the board, please try again later.",
          3,
          Colors.deepOrange,
        );
      } else {
        setState(() {
          boardID = jsonResponse['id'];
          boardTitle = jsonResponse['title'];
          boardType = jsonResponse['shared'];
          boardBudget = jsonResponse['budget'];
        });
      }
    }
  }

  _loadTransactionList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var lAPI = prefs.getString("api");
    var lEmail = prefs.getString("email");
    setState(() {
      apiKey = lAPI;
      email = lEmail;
    });
    var response =
        await http.post(Uri.parse(APIRoutes.getFinanceHistory), body: {
      "api": apiKey,
      "boardID": widget.id,
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
          transactionHistory = "empty";
        });
      } else {
        setState(() {
          transactionHistory = jsonResponse
              .map((history) => new TransactionHistory.fromJson(history))
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

  _buildTransactionList() {
    if (transactionHistory == "empty") {
      return NotFoundWidget(key: ValueKey(""));
    } else {
      return transactionHistory != null
          ? _historyListView(
              transactionHistory,
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
        return TransactionTile(
          amount: data[index].amount,
          reason: data[index].reason,
          createdBy: data[index].createdBy,
          isAddition: data[index].isAddition,
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainTabLayout(index: 2),
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
              _warnBoardDeletion(context);
            },
            icon: Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ],
        backgroundColor: Constants.backgroundColor,
        elevation: 0,
        title: boardTitle == null ? Text("...") : Text(boardTitle),
      ),
      backgroundColor: Constants.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Text(
                    "\$ $boardBudget",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: GestureDetector(
              onTap: () {
                _openTransactor(context, false);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [
                      Colors.redAccent,
                      Colors.deepOrange,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 5,
                  ),
                  child: Icon(
                    Icons.remove_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            trailing: GestureDetector(
              onTap: () {
                _openTransactor(context, true);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightGreen,
                      Colors.green,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 5,
                  ),
                  child: Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.withOpacity(0.3),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      AppLocalizations.of(context)!.transaction_history,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Divider(
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    height: 370,
                    child: _buildTransactionList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
