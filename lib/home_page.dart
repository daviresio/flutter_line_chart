import 'package:flutter/material.dart';

import 'line_chart_painter.dart';

//Chart data mocked
const List<ChartDataModel> chartData = [
  ChartDataModel(day: 15, value: 200.0),
  ChartDataModel(day: 16, value: 900.0),
  ChartDataModel(day: 17, value: 400.0),
  ChartDataModel(day: 18, value: 300.0),
  ChartDataModel(day: 19, value: 800.0),
  ChartDataModel(day: 20, value: 2000.0),
  ChartDataModel(day: 21, value: 1600.0),
  ChartDataModel(day: 22, value: 1000.0),
  ChartDataModel(day: 22, value: 1850.0),
  ChartDataModel(day: 23, value: 3000.0),
  ChartDataModel(day: 24, value: 2300.0),
  ChartDataModel(day: 25, value: 1500.0),
  ChartDataModel(day: 26, value: 3600.0),
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final Animation<double> _firstAnimation;
  late final Animation<double> _secondAnimation;
  late final Animation<double> _thirdAnimation;
  late final Animation<double> _fourthAnimation;

  double? positionX;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _animation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _firstAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.0, 0.5, curve: Curves.easeInOut)),
    );

    _secondAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.5, 0.7, curve: Curves.easeInOut)),
    );

    _thirdAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.7, 0.85, curve: Curves.easeInOut)),
    );

    _fourthAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _animationController,
          curve: const Interval(0.85, 1.0, curve: Curves.easeInOut)),
    );

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 60,
          height: 200,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                positionX = details.localPosition.dx;
              });
            },
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (_, __) {
                return CustomPaint(
                  painter: LineChartPainter(
                    chartData: chartData,
                    cursorPosition: positionX,
                    animation: _animation,
                    firstAnimation: _firstAnimation,
                    secondAnimation: _secondAnimation,
                    thirdAnimation: _thirdAnimation,
                    fourthAnimation: _fourthAnimation,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
