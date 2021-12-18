import 'package:workistant/config/constants.dart';
import 'package:workistant/views/changepassword.dart';
import 'package:workistant/views/welcome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsMenu extends StatefulWidget {
  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  var username;
  var email;
  var id;
  var api;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _api = prefs.getString("api");
    var _email = prefs.getString("email");
    var _id = prefs.getString("id");
    var _username = prefs.getString("display_name");
    setState(() {
      api = _api;
      email = _email;
      id = _id;
      username = _username;
    });
  }

  _confirmLogout(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          backgroundColor: Constants.backgroundColor,
          title: Text(
            AppLocalizations.of(context)!.logout,
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            AppLocalizations.of(context)!.sure_logout,
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: () {
                _logout(context);
              },
              child: Text(
                AppLocalizations.of(context)!.yes,
                style: TextStyle(color: Colors.green),
              ),
            ),
            // ignore: deprecated_member_use
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppLocalizations.of(context)!.no,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  _logout(ctx) async {
    Navigator.pop(ctx);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Constants.backgroundColor,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Constants.primaryColor,
                      Constants.secondaryColor,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Image(
                      image: AssetImage("assets/images/account.png"),
                      height: 150,
                      width: 150,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            email != null ? email : "...",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            username != null ? username : "...",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 4),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: Divider(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangePasswordScreen(),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.change_pass,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    leading: Icon(
                      Icons.vpn_key,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: Divider(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () async {
                    const url = "https://codecanyon.net/user/Gyconix";
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.buy_app,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    leading: Icon(
                      Icons.money_rounded,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: Divider(color: Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    _confirmLogout(context);
                  },
                  child: ListTile(
                    title: Text(
                      AppLocalizations.of(context)!.logout,
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 20,
                      ),
                    ),
                    leading: Icon(
                      Icons.power_settings_new,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
