import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  final reason;
  final createdBy;
  final amount;
  final isAddition;

  TransactionTile({
    this.reason,
    this.createdBy,
    this.amount,
    this.isAddition,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          ListTile(
            leading: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    gradient: LinearGradient(
                      colors: [
                        isAddition == "1" ? Colors.green : Colors.redAccent,
                        isAddition == "1"
                            ? Colors.lightGreen
                            : Colors.deepOrange,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 5,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          isAddition == "1"
                              ? Icons.add_circle_outline
                              : Icons.remove_circle_outline,
                          color: Colors.white,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 2,
                ),
                Text(
                  "\$$amount",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            title: Column(
              children: [
                Text(
                  reason,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  " - $createdBy",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80.0),
            child: Divider(
              color: Colors.white.withOpacity(
                0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
