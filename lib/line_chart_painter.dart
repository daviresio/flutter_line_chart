import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:useful_utils/useful_utils.dart' as util;

//Chart data model
class ChartDataModel {
  final int day;
  final double value;

  const ChartDataModel({
    required this.day,
    required this.value,
  });
}

class LineChartPainter extends CustomPainter {
  final List<ChartDataModel> chartData;

  const LineChartPainter({required this.chartData});

  @override
  void paint(Canvas canvas, Size size) {
    final higherValue = chartData.map((e) => e.value).reduce(math.max);
    final higherValueIndex =
        chartData.indexWhere((element) => element.value == higherValue);

    //Light gray horizontal lines
    drawHorizontalLines(canvas, size);

    final linePaint = Paint()
      ..color = Color(0xff5273EC)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(234, 238, 255, 1),
          Color.fromRGBO(234, 238, 255, 0),
        ],
      ).createShader(Rect.fromCenter(
          height: size.height,
          width: 0,
          center: Offset(size.width / 2, size.height / 2)));

    final linePath = Path();

    // Calculate positions X and Y of values
    final points = chartData.asMap().keys.toList().map((index) {
      final element = chartData[index];

      final positionY = size.height -
          util.remap(element.value, 0, higherValue, 0, size.height);

      final double positionX = util.remap(index.toDouble(), 0,
          (chartData.length - 1).toDouble(), 0, size.width);

      return Offset(positionX, positionY);
    }).toList();

    //Move path arround positions to draw lines
    for (var i = 0; i <= points.length - 1; i++) {
      if (i == 0) {
        linePath.moveTo(points.first.dx, points.first.dy);
      } else if (i != points.length - 1) {
        //If not is the first and last element generate lines with bezier
        final xMid = (points[i].dx + points[i + 1].dx) / 2;
        final yMid = (points[i].dy + points[i + 1].dy) / 2;
        final cpX1 = (xMid + points[i].dx) / 2;
        final cpX2 = (xMid + points[i + 1].dx) / 2;

        linePath.quadraticBezierTo(cpX1, points[i].dy, xMid, yMid);
        linePath.quadraticBezierTo(
            cpX2, points[i + 1].dy, points[i + 1].dx, points[i + 1].dy);
      }
    }

    final gradientPath = Path.from(linePath);

    // close area path
    gradientPath.lineTo(points.last.dx, size.height);
    gradientPath.lineTo(points.first.dx, size.height);
    gradientPath.lineTo(points.first.dx, points.first.dy);

    //Draw the gradient
    canvas.drawPath(gradientPath, gradientPaint);

    final outerCirclePainter = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xffD6DFFE);

    final innerCirclePainter = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    //Draw outer circle
    canvas.drawCircle(points[higherValueIndex], 10.0, outerCirclePainter);

    //Draw line chart
    canvas.drawPath(linePath, linePaint);

    //Draw inner white circle
    canvas.drawCircle(points[higherValueIndex], 3.0, innerCirclePainter);
    // Draw middle circle
    canvas.drawCircle(points[higherValueIndex], 4.0, linePaint);

    //Size and spacing of vertical indicator line
    const dashHeight = 6.0;
    const dashSpace = 6.0;

    var fromPositionY = points[higherValueIndex].dy + 4;
    //Begin on most higher value and when not is on bottom, draw lines
    while (size.height > fromPositionY) {
      final toPositionY = (size.height - fromPositionY) < dashHeight
          ? (fromPositionY + (size.height - fromPositionY))
          : fromPositionY + dashHeight;

      canvas.drawLine(
        Offset(points[higherValueIndex].dx, fromPositionY),
        Offset(points[higherValueIndex].dx, toPositionY),
        linePaint,
      );
      fromPositionY += dashHeight + dashSpace;
    }

    final textStyle = TextStyle(
      color: Colors.black38,
      fontSize: 12.0,
    );

    points.asMap().keys.forEach((index) {
      final offset = points[index];

      final textSpan = TextSpan(
        text: chartData[index].day.toString(),
        style: index == higherValueIndex
            ? textStyle.copyWith(fontWeight: FontWeight.bold)
            : textStyle,
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
          canvas, Offset(offset.dx - textPainter.width / 2, size.height));
    });

    drawTooltip(canvas, points[higherValueIndex], higherValue.toString());
  }

  drawTooltip(Canvas canvas, Offset offset, String text) {
    final textSpan = TextSpan(
      text: '\$$text',
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.0),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final rectPaint = Paint()
      ..color = Color(0xff414D62)
      ..style = PaintingStyle.fill;

    final rect = RRect.fromLTRBR(
      offset.dx - textPainter.width - 15 - 24,
      offset.dy - 10,
      offset.dx - 15,
      offset.dy + 10,
      Radius.circular(4.0),
    );

    canvas.drawRRect(rect, rectPaint);

    textPainter.paint(
        canvas,
        Offset(offset.dx - textPainter.width - 15 - 12,
            offset.dy - textPainter.height / 2));
  }

  drawHorizontalLines(Canvas canvas, Size size) {
    final horizontalLinePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke;

    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0),
      horizontalLinePaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.66)
        ..lineTo(size.width, size.height * 0.66),
      horizontalLinePaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.33)
        ..lineTo(size.width, size.height * 0.33),
      horizontalLinePaint,
    );

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height)
        ..lineTo(size.width, size.height),
      horizontalLinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
