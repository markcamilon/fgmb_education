import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ReminderPallete extends StatelessWidget {
  var id;
  var title;
  var time;
  var day;

  ReminderPallete({
    this.id,
    this.title,
    this.time,
    this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10,
      ),
      child: Row(
        children: [
          Column(
            children: [
              RotatedBox(
                quarterTurns: -1,
                child: Text(
                  time,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent,
                        Colors.purpleAccent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          title: Column(
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: Divider(color: Colors.white),
                              ),
                              Text(
                                day,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
