import 'dart:convert';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  final email;
  ResetPasswordScreen({this.email});
  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var _newPassword;

  bool _isSending = false;

  _changePassword() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        _isSending = true;
      });
      var response = await http.post(
        Uri.parse(APIRoutes.resetPassword),
        body: {
          "email": widget.email,
          "password": _newPassword,
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _isSending = false;
        });
        var jsonResponse = json.decode(response.body);
        if (jsonResponse == "success") {
          displaySnackBar(
            "Password was successfully changed, you can now proceed to log in.",
            5,
            Colors.green,
          );
        } else {
          displaySnackBar(
            "Request not sent, please try again later.",
            2,
            Colors.red,
          );
        }
      } else {
        setState(() {
          _isSending = false;
        });
        displaySnackBar(
          "Request not sent, please try again later.",
          2,
          Colors.red,
        );
      }
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
        backgroundColor: Constants.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Change Password",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 25),
                    child: TextFormField(
                      key: ValueKey('newpassword'),
                      validator: (val) {
                        if (val!.isEmpty || val.length < 6) {
                          return "Password should be atleast 6 characters long.";
                        }
                        return null;
                      },
                      obscureText: true,
                      onChanged: (value) {
                        setState(() {
                          _newPassword = value;
                        });
                      },
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'New Password',
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
              height: 10,
            ),
            if (!_isSending)
              GestureDetector(
                onTap: _changePassword,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      30,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Constants.primaryColor,
                        Constants.secondaryColor,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Change",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (_isSending)
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
