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
  final double? cursorPosition;
  final Animation<double> animation;
  final Animation<double> firstAnimation;
  final Animation<double> secondAnimation;
  final Animation<double> thirdAnimation;
  final Animation<double> fourthAnimation;

  const LineChartPainter({
    required this.chartData,
    required this.cursorPosition,
    required this.animation,
    required this.firstAnimation,
    required this.secondAnimation,
    required this.thirdAnimation,
    required this.fourthAnimation,
  });

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

    _drawGradient(
      canvas: canvas,
      animation: firstAnimation,
      linePath: linePath,
      points: points,
      size: size,
      endY: size.height,
    );

    final metrics = linePath.computeMetrics().toList();
    final metric = metrics.first;

    final drawLimit = util.remap(firstAnimation.value, 0, 1, 0, metric.length);

    var currentContourn = 0.0;
    final parcialPath = Path();

    while (currentContourn < drawLimit) {
      final contourn = metric.getTangentForOffset(currentContourn)!;
      if (currentContourn == 0) {
        parcialPath.moveTo(contourn.position.dx, contourn.position.dy);
      } else {
        parcialPath.lineTo(contourn.position.dx, contourn.position.dy);
      }
      currentContourn += 1;
    }

    canvas.drawPath(parcialPath, linePaint);

    late Offset cursorOffset;

    if (cursorPosition == null) {
      cursorOffset = points[higherValueIndex];
    } else {
      final straightLinePath = Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0);
      final straightLineMetrics =
          straightLinePath.computeMetrics().toList().first;

      final straightLineDistance = util.remap(
          cursorPosition!, 0, size.width, 0, straightLineMetrics.length);

      final straightLineContourn =
          straightLineMetrics.getTangentForOffset(straightLineDistance)!;

      final factor = metric.length / straightLineMetrics.length;

      final pathDistance =
          util.remap(cursorPosition!, 0, size.width, 0, metric.length);

      final pathContourn = metric.getTangentForOffset(pathDistance)!;

      final subtract =
          (pathContourn.position.dx - straightLineContourn.position.dx).abs();

      cursorOffset = metric
          .getTangentForOffset(pathDistance - subtract * factor)!
          .position;
    }

    _drawCircle(
      canvas: canvas,
      size: size,
      offset: cursorOffset,
      animation: thirdAnimation,
      linePaint: linePaint,
    );

    drawTooltip(
      canvas: canvas,
      offset: cursorOffset,
      text: util
          .remap(cursorOffset.dy, size.height, 0, 0, higherValue)
          .toInt()
          .toString(),
      animation: fourthAnimation,
    );

    points.asMap().keys.forEach((index) {
      final offset = points[index];

      final textSpan = TextSpan(
        text: chartData[index].day.toString(),
        style: TextStyle(
          color: Colors.black38,
          fontSize: 12.0,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
          canvas, Offset(offset.dx - textPainter.width / 2, size.height));
    });
  }

  void _drawGradient({
    required Canvas canvas,
    required Size size,
    required double endY,
    required Path linePath,
    required List<Offset> points,
    required Animation<double> animation,
  }) {
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

    final gradientPath = Path.from(linePath);

    // close area path
    gradientPath.lineTo(points.last.dx, size.height);
    gradientPath.lineTo(points.first.dx, size.height);
    gradientPath.lineTo(points.first.dx, points.first.dy);

    final bounds = gradientPath.getBounds();
    final matrix4 = Matrix4(
      1, 0, 0, 0, //
      0, util.remap(animation.value, 0, 1, 0, 1), 0, 0, //
      0, 0, 1, 0, //
      0, util.remap(animation.value, 0, 1, bounds.bottom, 0), 0,
      1, //
    );

    //Draw the gradient
    canvas.drawPath(gradientPath.transform(matrix4.storage), gradientPaint);
  }

  void _drawCircle({
    required Canvas canvas,
    required Size size,
    required Offset offset,
    required Animation<double> animation,
    required Paint linePaint,
  }) {
    final outerCirclePainter = Paint()
      ..style = PaintingStyle.fill
      ..color = Color(0xffD6DFFE);

    final innerCirclePainter = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final matrixScale = Matrix4.identity();
    matrixScale.translate(util.remap(animation.value, 0, 1, offset.dx, 0),
        util.remap(animation.value, 0, 1, offset.dy, 0));
    matrixScale.scale(animation.value, animation.value);

    final bigCirclePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCircle(center: offset, radius: 10), Radius.circular(10)));

    final smallCirclePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCircle(center: offset, radius: 3), Radius.circular(3)));

    final mediumCirclePath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Rect.fromCircle(center: offset, radius: 4), Radius.circular(4)));

    canvas.drawPath(
      bigCirclePath.transform(matrixScale.storage),
      outerCirclePainter,
    );

    canvas.drawPath(
      smallCirclePath.transform(matrixScale.storage),
      innerCirclePainter,
    );

    canvas.drawPath(
      mediumCirclePath.transform(matrixScale.storage),
      linePaint,
    );

    final path = _verticalDashedLine(
      dashHeight: 6,
      dashSpace: 6,
      dx: offset.dx,
      startY:
          util.remap(secondAnimation.value, 0, 1, size.height, offset.dy + 4),
      endY: size.height,
    );

    canvas.drawPath(path, linePaint);
  }

  Path _verticalDashedLine({
    required double dashHeight,
    required double dashSpace,
    required double startY,
    required double endY,
    required double dx,
  }) {
    final path = Path();
    var positionY = startY;
    while (endY > positionY) {
      if ((endY - positionY) < dashHeight) {
        path.moveTo(dx, positionY);
        path.lineTo(dx, positionY + (endY - positionY));
      } else {
        path.moveTo(dx, positionY);
        path.lineTo(dx, positionY + dashHeight);
      }
      positionY += dashHeight + (dashSpace + 1);
    }

    return path;
  }

  drawTooltip({
    required Canvas canvas,
    required Offset offset,
    required String text,
    required Animation<double> animation,
  }) {
    final textSpan = TextSpan(
      text: '\$$text',
      style: TextStyle(
        color: Colors.white.withOpacity(animation.value),
        fontWeight: FontWeight.bold,
        fontSize: 12.0,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final rectPaint = Paint()
      ..color = Color(0xff414D62).withOpacity(animation.value)
      ..style = PaintingStyle.fill;

    const translateX = 15.0;
    final translatedX = util.remap(animation.value, 0, 1, 0, translateX);

    final rect = RRect.fromLTRBR(
      offset.dx - textPainter.width - translatedX - 24,
      offset.dy - 10,
      offset.dx - translatedX,
      offset.dy + 10,
      Radius.circular(4.0),
    );

    canvas.drawRRect(rect, rectPaint);

    textPainter.paint(
      canvas,
      Offset(offset.dx - textPainter.width - translatedX - 12,
          offset.dy - textPainter.height / 2),
    );
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
