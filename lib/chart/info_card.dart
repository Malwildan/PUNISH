import 'package:flutter/material.dart';

class infocard extends StatelessWidget {

  final String title;
  final String value;

  const infocard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 100,
        height: 100,
        padding: 
        EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),), SizedBox(height: 8,), Text(title, textAlign: TextAlign.center,)],
        ),
      ),
    );
  }
}