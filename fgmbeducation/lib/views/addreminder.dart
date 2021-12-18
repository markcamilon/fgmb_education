import 'dart:convert';
import 'dart:math';
import 'package:workistant/components/reminderErrorDisplay.dart';
import 'package:workistant/config/apiRoutes.dart';
import 'package:workistant/config/constants.dart';
import 'package:workistant/views/MainTabLayout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:group_button/group_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReminderAdder extends StatefulWidget {
  @override
  _ReminderAdderState createState() => _ReminderAdderState();
}

class _ReminderAdderState extends State<ReminderAdder> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _adderKey = GlobalKey<FormState>();
  late String _reminderMessage;
  List<String> _reminderDays = [];
  var formDate;
  bool checkBoxValue = true;

  int error = 0;

  DateTime _date = new DateTime.now();
  TimeOfDay formTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);

  var _rawSelectedDate;
  var _rawSelectedTime;

  @override
  void initState() {
    super.initState();
    _configureLocalTimeZone();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings("@mipmap/ic_launcher");
    var ios = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android: android, iOS: ios);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String currentTimeZone =
        await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  Future<void> _scheduleWeeklyNotification(
      notificationDay, String notificationMessage, int notificationID) async {
    Day scheduledDay = Day.monday;
    if (notificationDay == "Monday") {
      setState(() {
        scheduledDay = Day.monday;
      });
    } else if (notificationDay == "Tuesday") {
      setState(() {
        scheduledDay = Day.tuesday;
      });
    } else if (notificationDay == "Wednesday") {
      setState(() {
        scheduledDay = Day.wednesday;
      });
    } else if (notificationDay == "Thursday") {
      setState(() {
        scheduledDay = Day.thursday;
      });
    } else if (notificationDay == "Friday") {
      setState(() {
        scheduledDay = Day.friday;
      });
    } else if (notificationDay == "Saturday") {
      setState(() {
        scheduledDay = Day.saturday;
      });
    } else if (notificationDay == "Sunday") {
      setState(() {
        scheduledDay = Day.sunday;
      });
    }
    // ignore: deprecated_member_use
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      notificationID,
      "Workistant Weekly Reminder",
      notificationMessage,
      scheduledDay,
      Time(
        _rawSelectedTime.hour,
        _rawSelectedTime.minute,
        0,
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          'your channel description',
        ),
      ),
    );
  }

  _scheduleOneTimeNotification(
      int notificationKey, String reminderMessage) async {
    var finalDate = new DateTime(
      _rawSelectedDate.year,
      _rawSelectedDate.month,
      _rawSelectedDate.day,
      _rawSelectedTime.hour,
      _rawSelectedTime.minute,
    );
    var rawDifference = double.parse(
      DateTime.now().difference(finalDate).inSeconds.toString(),
    );
    var doubleDifference = rawDifference /= -1;
    final difference = doubleDifference.toInt();
    await flutterLocalNotificationsPlugin.zonedSchedule(
      notificationKey,
      'Workistant Reminder',
      reminderMessage,
      tz.TZDateTime.now(tz.local).add(
        Duration(
          seconds: difference,
        ),
      ),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          'your channel description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<Null> _selectDate(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      print(pickedDate.toString());
      setState(() {
        _date = pickedDate;
        _rawSelectedDate = pickedDate;
      });
      _loadDate(pickedDate.toString());
    }
  }

  Future<Null> _selectTime(BuildContext context) async {
    FocusScope.of(context).unfocus();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        DateTime.now().add(
          Duration(minutes: 1),
        ),
      ),
    );
    if (pickedTime != null) {
      print(pickedTime.toString());
      setState(() {
        formTime = pickedTime;
        _rawSelectedTime = pickedTime;
      });
    }
  }

  _loadDate(receivedDate) async {
    var date = receivedDate;

    var dateParse = DateTime.parse(date);

    var weekDay = _determineWeekDay(dateParse.weekday);
    var month = _determineMonth(dateParse.month);

    var formattedDate = "$weekDay, $month ${dateParse.day}, ${dateParse.year}";

    setState(() {
      formDate = formattedDate.toString();
    });
  }

  validateFieldsChecked() {
    print("checked");
    if (formDate == null) {
      return 1;
      // ignore: unnecessary_null_comparison
    } else if (formTime == null) {
      return 2;
      // ignore: unnecessary_null_comparison
    } else if (formDate == null && formTime == null) {
      return 3;
    } else {
      return "proceed";
    }
  }

  validateFieldsUnchecked() {
    print("unchecked");
    if (_reminderDays.length == 0) {
      return 4;
      // ignore: unnecessary_null_comparison
    } else if (formTime == null) {
      return 2;
      // ignore: unnecessary_null_comparison
    } else if (_reminderDays.length == 0 && formTime == null) {
      return 5;
    } else {
      return "proceed";
    }
  }

  _addReminder() async {
    FocusScope.of(context).unfocus();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var apiKey = prefs.getString("api");
    var type = checkBoxValue ? "0" : "1";
    var notificationKey;
    List notificationKeys = [];
    if (checkBoxValue) {
      var notificationKeyRaw = "";
      var rnd = new Random();
      for (var i = 0; i < 6; i++) {
        notificationKeyRaw = notificationKeyRaw + rnd.nextInt(9).toString();
      }
      notificationKey = int.parse(notificationKeyRaw);
      _scheduleOneTimeNotification(notificationKey, _reminderMessage);
    } else {
      _reminderDays.forEach((element) {
        var notificationKeyRaw = "";
        var rnd = new Random();
        for (var i = 0; i < 6; i++) {
          notificationKeyRaw = notificationKeyRaw + rnd.nextInt(9).toString();
        }
        setState(() {
          notificationKeys.add(notificationKeyRaw);
        });
        print(notificationKeys);
        _scheduleWeeklyNotification(
          element,
          _reminderMessage,
          int.parse(
            notificationKeyRaw,
          ),
        );
      });
    }
    String rawDays = json.encode(_reminderDays);
    var bracketRemovedDays = rawDays.replaceAll("[", "");
    var bracketRemovedDays2 = bracketRemovedDays.replaceAll("]", "");
    var invertedRemovedDays = bracketRemovedDays2.replaceAll("\"", "");
    var finalDays = invertedRemovedDays.replaceAll(",", ", ");
    var response = await http.post(
      Uri.parse(APIRoutes.addReminder),
      body: {
        "api": apiKey,
        "message": _reminderMessage,
        "type": type,
        "time": formTime.format(context),
        "day": checkBoxValue ? formDate : finalDays,
        "notificationKey": checkBoxValue
            ? notificationKey.toString()
            : jsonEncode(notificationKeys),
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      if (jsonResponse == "success") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainTabLayout(index: 3),
          ),
        );
      } else {
        displaySnackBar(
          "An error occured while adding your reminder, please try again later.",
          3,
          Colors.red,
        );
      }
    } else {
      displaySnackBar(
        "An error occured while adding your reminder, please try again later.",
        3,
        Colors.red,
      );
    }
  }

  String _determineWeekDay(weekday) {
    if (weekday == 1) {
      return "Monday";
    } else if (weekday == 2) {
      return "Tuesday";
    } else if (weekday == 3) {
      return "Wednesday";
    } else if (weekday == 4) {
      return "Thursday";
    } else if (weekday == 5) {
      return "Friday";
    } else if (weekday == 6) {
      return "Saturday";
    } else if (weekday == 7) {
      return "Sunday";
    }
    return "Today";
  }

  String _determineMonth(month) {
    if (month == 1) {
      return "January";
    } else if (month == 2) {
      return "February";
    } else if (month == 3) {
      return "March";
    } else if (month == 4) {
      return "April";
    } else if (month == 5) {
      return "May";
    } else if (month == 6) {
      return "June";
    } else if (month == 7) {
      return "July";
    } else if (month == 8) {
      return "August";
    } else if (month == 9) {
      return "September";
    } else if (month == 10) {
      return "October";
    } else if (month == 11) {
      return "November";
    } else if (month == 12) {
      return "December";
    }
    return "month";
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => MainTabLayout(index: 3),
              ),
            );
          },
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Constants.backgroundColor,
      ),
      backgroundColor: Constants.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.add_reminder,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _adderKey,
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _reminderMessage = value;
                        });
                      },
                      // ignore: missing_return
                      validator: (val) {
                        if (val!.length < 1) {
                          return "This field can't be left empty.";
                        }
                      },
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.reminder_message,
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
                    GestureDetector(
                      onTap: () {
                        _selectTime(context);
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            // ignore: unnecessary_null_comparison
                            formTime == null
                                ? "Select Time"
                                : formTime.format(context),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withAlpha(210),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          checkBoxValue = !checkBoxValue;
                        });
                      },
                      child: ListTile(
                        leading: Checkbox(
                          value: checkBoxValue,
                          checkColor: Colors.white,
                          activeColor: Constants.secondaryColor,
                          onChanged: (val) => setState(
                            () {
                              checkBoxValue = !checkBoxValue;
                              _reminderDays = [];
                            },
                          ),
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.remind_once,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    if (checkBoxValue)
                      GestureDetector(
                        onTap: () {
                          _selectDate(context);
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              formDate == null
                                  ? AppLocalizations.of(context)!.select_date
                                  : formDate,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withAlpha(210),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!checkBoxValue)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Center(
                          child: GroupButton(
                            spacing: 8,
                            selectedColor: Constants.secondaryColor,
                            selectedBorderColor: Colors.white,
                            unselectedBorderColor: Colors.black,
                            isRadio: false,
                            direction: Axis.horizontal,
                            onSelected: (index, isSelected) {
                              var _day;
                              if (index == 0) {
                                _day = "Monday";
                              } else if (index == 1) {
                                _day = "Tuesday";
                              } else if (index == 2) {
                                _day = "Wednesday";
                              } else if (index == 3) {
                                _day = "Thursday";
                              } else if (index == 4) {
                                _day = "Friday";
                              } else if (index == 5) {
                                _day = "Saturday";
                              } else if (index == 6) {
                                _day = "Sunday";
                              }
                              isSelected
                                  ? _reminderDays.add(_day)
                                  : _reminderDays.remove(_day);
                              print(_reminderDays);
                            },
                            buttons: [
                              "Monday",
                              "Tuesday",
                              "Wednesday",
                              "Thursday",
                              "Friday",
                              "Saturday",
                              "Sunday",
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: checkBoxValue ? 20 : 5),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Divider(
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    if (error != 0)
                      ReminderErrorDisplay(
                        errorCode: error,
                      ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 65,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          final isValid = _adderKey.currentState!.validate();
                          if (isValid) {
                            var validationResponse = checkBoxValue
                                ? validateFieldsChecked()
                                : validateFieldsUnchecked();
                            if (validationResponse == "proceed") {
                              setState(() {
                                error = 0;
                              });
                              _addReminder();
                            } else {
                              setState(() {
                                error = validationResponse;
                              });
                            }
                          }
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
                            padding: const EdgeInsets.all(
                              10.0,
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add_alarm_rounded,
                                    color: Colors.white,
                                  ),
                                  Spacer(),
                                  Text(
                                    AppLocalizations.of(context)!.add,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
