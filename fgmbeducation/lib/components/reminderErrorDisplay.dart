import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReminderErrorDisplay extends StatelessWidget {
  int errorCode;

  ReminderErrorDisplay({
    required this.errorCode,
  });

  // ignore: missing_return
  String errorSetup() {
    if (errorCode == 1) {
      return "Please select a valid date first.";
    } else if (errorCode == 2) {
      return "Please select a valid time first.";
    } else if (errorCode == 3) {
      return "Please select a valid date and time first.";
    } else if (errorCode == 4) {
      return "Please select atleast a day of the week";
    } else if (errorCode == 5) {
      return "Please select a day of the week and a valid time.";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        errorSetup(),
        style: TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }
}
