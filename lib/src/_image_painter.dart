import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;

import 'controller.dart';
import 'drawing_utils.dart';
import 'paint_info.dart';
import 'paint_mode.dart';

///Handles all the painting ongoing on the canvas.
class DrawImage extends CustomPainter {
  ///The background for signature painting.
  final Color? backgroundColor;

  //Controller is a listenable with all of the paint details.
  late ImagePainterController _controller;

  ///Constructor for the canvas
  DrawImage({
    required ImagePainterController controller,
    this.backgroundColor,
  }) : super(repaint: controller) {
    _controller = controller;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackgroundImage(canvas, size);
    _paintHistory(canvas, size);
    _paintCurrentDrawing(canvas);
  }

  void _paintBackgroundImage(Canvas canvas, Size size) {
    paintImage(
      canvas: canvas,
      image: _controller.image!,
      filterQuality: FilterQuality.high,
      rect: Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
    );
  }

  void _paintHistory(Canvas canvas, Size size) {
    for (final item in _controller.paintHistory) {
      switch (item.mode) {
        case PaintMode.rect:
          _paintRectangle(canvas, item);
          break;
        case PaintMode.line:
          _paintLine(canvas, item);
          break;
        case PaintMode.circle:
          _paintCircle(canvas, item);
          break;
        case PaintMode.arrow:
          _paintArrow(canvas, item);
          break;
        case PaintMode.dashLine:
          _paintDashLine(canvas, item);
          break;
        case PaintMode.freeStyle:
          _paintFreeStyle(canvas, item);
          break;
        case PaintMode.text:
          _paintText(canvas, item, size);
          break;
        default:
        // Handle other modes or do nothing
      }
    }
  }

  void _paintCurrentDrawing(Canvas canvas) {
    if (!_controller.busy) return;

    final start = _controller.start;
    final end = _controller.end;
    final paint = _controller.brush;

    switch (_controller.mode) {
      case PaintMode.rect:
        canvas.drawRect(Rect.fromPoints(start!, end!), paint);
        break;
      case PaintMode.line:
        canvas.drawLine(start!, end!, paint);
        break;
      case PaintMode.circle:
        _drawCircle(canvas, start!, end!, paint);
        break;
      case PaintMode.arrow:
        DrawingUtils.drawArrow(canvas, start!, end!, paint);
        break;
      case PaintMode.dashLine:
        _drawDashLine(canvas, start!, end!, paint);
        break;
      case PaintMode.freeStyle:
        _drawFreeStyle(canvas, _controller.offsets, paint);
        break;
      default:
      // Handle other modes or do nothing
    }
  }

  // Implement individual painting methods here, e.g.:
  void _paintRectangle(Canvas canvas, PaintInfo item) {
    canvas.drawRect(
        Rect.fromPoints(item.offsets[0]!, item.offsets[1]!), item.paint);
    if (item.selected) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path()
        ..addRect(Rect.fromPoints(item.offsets[0]!, item.offsets[1]!));
      canvas.drawPath(DrawingUtils.dashPath(path, paint.strokeWidth), paint);
    }
  }

  void _paintLine(Canvas canvas, PaintInfo item) {
    canvas.drawLine(item.offsets[0]!, item.offsets[1]!, item.paint);
    if (item.selected) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path()
        ..moveTo(item.offsets[0]!.dx, item.offsets[0]!.dy)
        ..lineTo(item.offsets[1]!.dx, item.offsets[1]!.dy);
      canvas.drawPath(DrawingUtils.dashPath(path, paint.strokeWidth), paint);
    }
  }

  void _paintCircle(Canvas canvas, PaintInfo item) {
    final path = Path();
    path.addOval(
      Rect.fromCircle(
          center: item.offsets[1]!,
          radius: (item.offsets[0]! - item.offsets[1]!).distance),
    );
    canvas.drawPath(path, item.paint);
    if (item.selected) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path();
      path.addOval(Rect.fromCircle(
          center: item.offsets[1]!,
          radius: (item.offsets[0]! - item.offsets[1]!).distance));
      canvas.drawPath(DrawingUtils.dashPath(path, paint.strokeWidth), paint);
    }
  }

  void _paintArrow(Canvas canvas, PaintInfo item) {
    DrawingUtils.drawArrow(
        canvas, item.offsets[0]!, item.offsets[1]!, item.paint);
    if (item.selected) {
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path()
        ..moveTo(item.offsets[0]!.dx, item.offsets[0]!.dy)
        ..lineTo(item.offsets[1]!.dx, item.offsets[1]!.dy);
      canvas.drawPath(DrawingUtils.dashPath(path, paint.strokeWidth), paint);
      DrawingUtils.drawArrow(canvas, item.offsets[0]!, item.offsets[1]!, paint);
    }
  }

  void _paintDashLine(Canvas canvas, PaintInfo item) {
    final path = Path()
      ..moveTo(item.offsets[0]!.dx, item.offsets[0]!.dy)
      ..lineTo(item.offsets[1]!.dx, item.offsets[1]!.dy);
    canvas.drawPath(
        DrawingUtils.dashPath(path, item.paint.strokeWidth), item.paint);
  }

  void _paintFreeStyle(Canvas canvas, PaintInfo item) {
    final offsets = item.offsets;
    final painter = item.paint;
    for (int i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null && offsets[i + 1] != null) {
        final path = Path()
          ..moveTo(offsets[i]!.dx, offsets[i]!.dy)
          ..lineTo(offsets[i + 1]!.dx, offsets[i + 1]!.dy);
        canvas.drawPath(path, painter..strokeCap = StrokeCap.round);
      } else if (offsets[i] != null && offsets[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points, [offsets[i]!],
            painter..strokeCap = ui.StrokeCap.round);
      }
    }
  }

  void _paintText(Canvas canvas, PaintInfo item, Size size) {
    final textSpan = TextSpan(
      text: item.text,
      style: TextStyle(
        color: item.paint.color,
        fontSize: 6 * item.paint.strokeWidth,
        fontWeight: FontWeight.bold,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    final textOffset = item.offsets.isEmpty
        ? Offset(size.width / 2 - textPainter.width / 2,
            size.height / 2 - textPainter.height / 2)
        : Offset(item.offsets[0]!.dx - textPainter.width / 2,
            item.offsets[0]!.dy - textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
    if (item.selected) {
      final rect = Rect.fromLTWH(
          textOffset.dx, textOffset.dy, textPainter.width, textPainter.height);
      final paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final path = Path()..addRect(rect);
      canvas.drawPath(DrawingUtils.dashPath(path, paint.strokeWidth), paint);
    }
  }

  void _drawCircle(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: end, radius: (end - start).distance));
    canvas.drawPath(path, paint);
  }

  void _drawDashLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..lineTo(end.dx, end.dy);
    canvas.drawPath(DrawingUtils.dashPath(path, paint.strokeWidth), paint);
  }

  void _drawFreeStyle(Canvas canvas, List<Offset?> points, Paint paint) {
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
            Offset(points[i]!.dx, points[i]!.dy),
            Offset(points[i + 1]!.dx, points[i + 1]!.dy),
            paint..strokeCap = StrokeCap.round);
      } else if (points[i] != null && points[i + 1] == null) {
        canvas.drawPoints(ui.PointMode.points,
            [ui.Offset(points[i]!.dx, points[i]!.dy)], paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawImage oldInfo) {
    return oldInfo._controller != _controller;
  }
}

///All the paint method available for use.
