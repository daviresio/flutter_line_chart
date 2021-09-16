import 'package:flutter/material.dart';

import 'line_chart_painter.dart';

//Chart data mocked
const List<ChartDataModel> chartData = [
  ChartDataModel(day: 21, value: 900.0),
  ChartDataModel(day: 22, value: 1100.0),
  ChartDataModel(day: 23, value: 1400.0),
  ChartDataModel(day: 24, value: 1850.0),
  ChartDataModel(day: 25, value: 2300.0),
  ChartDataModel(day: 26, value: 3200.0),
];

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width - 60, 200),
          painter: LineChartPainter(chartData: chartData),
        ),
      ),
    );
  }
}
