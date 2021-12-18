import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BoardTile extends StatelessWidget {
  var title;
  var type;

  BoardTile({
    this.title,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.purple,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 14,
          ),
          child: ListTile(
            title: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "($type)",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
