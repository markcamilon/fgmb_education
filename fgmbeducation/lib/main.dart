import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workistant/l10n/l10n.dart';
import 'package:workistant/views/MainTabLayout.dart';
import 'package:workistant/views/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  var homeScreen = email == null ? WelcomeScreen() : MainTabLayout(index: 0);
  runApp(MyApp(child: homeScreen));
}

class MyApp extends StatefulWidget {
  final child;

  MyApp({this.child});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: "DMSans",
      ),
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: widget.child,
    );
  }
}
