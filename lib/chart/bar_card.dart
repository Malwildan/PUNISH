import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class barcard extends StatelessWidget {
  final String title;
  final List<BarChartGroupData> data;

  barcard({required this.title, required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        height: 200,
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(title),
            Expanded(
              child: BarChart(
                BarChartData(
                  barGroups: data,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 4.0,
                            child: Text(value.toInt().toString()),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}