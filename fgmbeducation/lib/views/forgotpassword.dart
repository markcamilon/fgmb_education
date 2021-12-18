import 'dart:convert';

import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/views/resetpassword.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _verifierFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isLoading = false;

  String _userEmail = "";
  var _verificationKey;

  _sendVerificationEmail(context) async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isLoading = true;
      });
      var response = await http.post(
        Uri.parse(APIRoutes.attemptReset),
        body: {
          "email": _userEmail,
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        setState(() {
          _isLoading = false;
        });
        if (jsonResponse == "error") {
          displaySnackBar(
            "An error occured while submitting your request, Please try again later.",
            3,
            Colors.red,
          );
        } else if (jsonResponse == "notfound") {
          displaySnackBar(
            "No account found associated to the provided email.",
            3,
            Colors.deepOrange,
          );
        } else {
          _openVerificationBox(context);
        }
      } else {
        displaySnackBar(
          "An error occured while submitting your request, Please try again later.",
          3,
          Colors.red,
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  _openVerificationBox(BuildContext context) {
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
            "Verify OTP",
            style: TextStyle(color: Colors.white),
          ),
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Check your email for a verificaiton code and enter it here",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _verifierFormKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: _userEmail,
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
                            hintText: 'Email',
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
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          enableInteractiveSelection: false,
                          enableSuggestions: false,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _verificationKey = value;
                            });
                          },
                          // ignore: missing_return
                          validator: (val) {
                            if (val!.length < 1) {
                              return "Please enter a valid key";
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Verification Key',
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
                    final isValid = _verifierFormKey.currentState!.validate();
                    if (isValid) {
                      Navigator.pop(context);
                      setState(() {
                        _isLoading = true;
                      });
                      _verifyEnteredKey();
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
                        "Verify",
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

  _verifyEnteredKey() async {
    var response = await http.post(
      Uri.parse(APIRoutes.verifyOTP),
      body: {
        "email": _userEmail,
        "verificationKey": _verificationKey,
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
      });
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "error") {
        displaySnackBar(
          "An error occured while submitting your request, Please try again later.",
          3,
          Colors.red,
        );
      } else if (jsonResponse == "notfound") {
        displaySnackBar(
          "No account found associated to the provided email.",
          3,
          Colors.deepOrange,
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: _userEmail),
          ),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      displaySnackBar(
        "An error occured while submitting your request, Please try again later.",
        3,
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
        elevation: 0,
        backgroundColor: Constants.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "Reset Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
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
                        hintText: 'Email',
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
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Enter your account email to receive a verification code",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (!_isLoading)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 46),
                child: GestureDetector(
                  onTap: () {
                    _sendVerificationEmail(context);
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
                        "Send Verification Code",
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
            if (!_isLoading)
              GestureDetector(
                onTap: () {
                  _openVerificationBox(context);
                },
                child: Center(
                  child: Text(
                    "Already have a code?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            if (_isLoading)
              SizedBox(
                height: 20,
              ),
            if (_isLoading)
              LoadingBouncingGrid.square(
                backgroundColor: Constants.secondaryColor,
                borderColor: Constants.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}
