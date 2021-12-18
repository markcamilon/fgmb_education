import 'dart:convert';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/views/MainTabLayout.dart';
import 'package:workistant/views/forgotpassword.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  final bool isLogin;

  AuthScreen({required this.isLogin});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLogin = false;
  bool _isLoading = false;

  String _userEmail = "";
  String _displayName = "";
  String _userPassword = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLogin = widget.isLogin;
    });
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(
      const Duration(seconds: 10),
      () {
        if (_isLoading) {
          setState(() {
            _isLoading = false;
          });
          displaySnackBar(
            "An unknown error occured, Please try again later",
            3,
            Colors.red,
          );
        }
      },
    );
    print("continue");
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      var response = await http.post(
        Uri.parse(APIRoutes.loginUser),
        body: {
          "email": _userEmail,
          "password": _userPassword,
        },
      );
      var statusCode = response.statusCode;
      var data = json.decode(response.body);

      if (statusCode != 200) {
        displaySnackBar(
          AppLocalizations.of(context)!.error_occured,
          3,
          Colors.red,
        );
      } else {
        var responseCode = data['code'].toString();
        if (responseCode == "4") {
          displaySnackBar(
            AppLocalizations.of(context)!.no_acc_reg,
            3,
            Colors.red,
          );
        } else if (responseCode == "5") {
          displaySnackBar(
            "Invalid password, please try again.",
            3,
            Colors.red,
          );
        } else if (responseCode == "6") {
          var email = data["account"]["email"].toString();
          var displayName = data["account"]["display_name"].toString();
          var api = data["account"]["api"].toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', email);
          prefs.setString('display_name', displayName);
          prefs.setString('api', api);
          displaySnackBar(
            "Logged in. Welcome to Workistant.",
            2,
            Colors.black,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainTabLayout(index: 0),
            ),
          );
        } else {
          displaySnackBar(
            AppLocalizations.of(context)!.error_occured,
            3,
            Colors.red,
          );
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _handleSignUp() async {
    setState(() {
      _isLoading = true;
    });
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      var response = await http.post(
        Uri.parse(APIRoutes.registerUser),
        body: {
          "email": _userEmail,
          "password": _userPassword,
          "display_name": _displayName,
        },
      );
      var statusCode = response.statusCode;
      var data = json.decode(response.body);

      if (statusCode != 200) {
        displaySnackBar(
          AppLocalizations.of(context)!.error_occured,
          3,
          Colors.red,
        );
      } else {
        var responseCode = data['code'].toString();
        if (responseCode == "3") {
          displaySnackBar(
            "This username is taken, please choose a different one.",
            3,
            Colors.red,
          );
        } else if (responseCode == "2") {
          displaySnackBar(
            "This email is already registered, Try signing in.",
            3,
            Colors.red,
          );
        } else if (responseCode == "0") {
          var email = data["account"]["email"].toString();
          var displayName = data["account"]["display_name"].toString();
          var api = data["account"]["api"].toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', email);
          prefs.setString('display_name', displayName);
          prefs.setString('api', api);
          displaySnackBar(
            "Account Registered. Welcome to Workistant.",
            2,
            Colors.black,
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MainTabLayout(index: 0),
            ),
          );
        } else {
          displaySnackBar(
            AppLocalizations.of(context)!.error_occured,
            3,
            Colors.red,
          );
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
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
        child: ListView(
          children: <Widget>[
            SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.only(left: 25.0),
              child: Text(
                _isLogin
                    ? AppLocalizations.of(context)!.welcome_back
                    : AppLocalizations.of(context)!.create_acc,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 25),
                    child: TextFormField(
                      key: ValueKey('email'),
                      validator: (val) {
                        if (val!.isEmpty || !val.contains("@")) {
                          return "Please enter a valid email address.";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          _userEmail = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.email,
                        hintStyle: TextStyle(
                          fontSize: 17,
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
                  if (!_isLogin)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 25),
                      child: TextFormField(
                        key: ValueKey('display_name'),
                        validator: (val) {
                          if (val!.isEmpty || val.length < 4) {
                            return "Display Name should be atleast 4 characters long.";
                          }
                          if (val.length > 15) {
                            return "Display Name should not be longer than 15 characters.";
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _displayName = value;
                          });
                        },
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.f_n,
                          hintStyle: TextStyle(
                            fontSize: 17,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 25),
                    child: TextFormField(
                      key: ValueKey('password'),
                      validator: (val) {
                        if (val!.isEmpty || val.length < 6) {
                          return "Password should be atleast 6 characters long.";
                        }
                        return null;
                      },
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _userPassword = value;
                        });
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.password,
                        hintStyle: TextStyle(
                          fontSize: 17,
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
                  if (_isLoading)
                    SizedBox(
                      height: 75,
                    ),
                  if (_isLoading)
                    LoadingBouncingGrid.square(
                      backgroundColor: Constants.secondaryColor,
                      borderColor: Constants.primaryColor,
                    ),
                  if (_isLoading)
                    SizedBox(
                      height: 25,
                    ),
                  if (_isLoading)
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.processing,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            if (!_isLoading)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                child: GestureDetector(
                  onTap: () {
                    _isLogin ? _handleLogin() : _handleSignUp();
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [
                          Constants.primaryColor,
                          Constants.secondaryColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _isLogin
                            ? AppLocalizations.of(context)!.log_in
                            : AppLocalizations.of(context)!.register,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 30,
            ),
            if (!_isLoading)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.forgot_pass,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            SizedBox(
              height: 10,
            ),
            if (!_isLoading)
              Center(
                // ignore: deprecated_member_use
                child: FlatButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? AppLocalizations.of(context)!.no_acc_reg
                        : AppLocalizations.of(context)!.already_account,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
