import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class piecard extends StatelessWidget {
  //const piechart({super.key});

  final String title;
  final List<PieChartSectionData> data;

  const piecard({super.key, required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 200,
        height: 200,
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Text(title),
            Expanded(
              child: PieChart(PieChartData(sections: data, centerSpaceRadius: 30, sectionsSpace: 2)))
          ],
        ),
      ),
    );
  }
}