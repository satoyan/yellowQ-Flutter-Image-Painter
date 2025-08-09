import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;

import 'controller.dart';
import 'drawing_utils.dart';
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
    ///paints [ui.Image] on the canvas for reference to draw over it.
    paintImage(
      canvas: canvas,
      image: _controller.image!,
      filterQuality: FilterQuality.high,
      rect: Rect.fromPoints(
        const Offset(0, 0),
        Offset(size.width, size.height),
      ),
    );

    ///paints all the previous paintInfo history recorded on [PaintHistory]
    for (final item in _controller.paintHistory) {
      final _offset = item.offsets;
      final _painter = item.paint;
      switch (item.mode) {
        case PaintMode.rect:
          canvas.drawRect(Rect.fromPoints(_offset[0]!, _offset[1]!), _painter);
          if (item.selected) {
            final paint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            final path = Path()
              ..addRect(Rect.fromPoints(_offset[0]!, _offset[1]!));
            canvas.drawPath(
                DrawingUtils.dashPath(path, paint.strokeWidth), paint);
          }
          break;
        case PaintMode.line:
          canvas.drawLine(_offset[0]!, _offset[1]!, _painter);
          if (item.selected) {
            final paint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            final path = Path()
              ..moveTo(_offset[0]!.dx, _offset[0]!.dy)
              ..lineTo(_offset[1]!.dx, _offset[1]!.dy);
            canvas.drawPath(
                DrawingUtils.dashPath(path, paint.strokeWidth), paint);
          }
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(
            Rect.fromCircle(
                center: _offset[1]!,
                radius: (_offset[0]! - _offset[1]!).distance),
          );
          canvas.drawPath(path, _painter);
          if (item.selected) {
            final paint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            final path = Path();
            path.addOval(Rect.fromCircle(
                center: _offset[1]!,
                radius: (_offset[0]! - _offset[1]!).distance));
            canvas.drawPath(
                DrawingUtils.dashPath(path, paint.strokeWidth), paint);
          }
          break;
        case PaintMode.arrow:
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
            canvas.drawPath(
                DrawingUtils.dashPath(path, paint.strokeWidth), paint);
            DrawingUtils.drawArrow(
                canvas, item.offsets[0]!, item.offsets[1]!, paint);
          }
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(item.offsets[0]!.dx, item.offsets[0]!.dy)
            ..lineTo(item.offsets[1]!.dx, item.offsets[1]!.dy);
          canvas.drawPath(
              DrawingUtils.dashPath(path, item.paint.strokeWidth), item.paint);
          break;
        case PaintMode.freeStyle:
          for (int i = 0; i < _offset.length - 1; i++) {
            if (_offset[i] != null && _offset[i + 1] != null) {
              final _path = Path()
                ..moveTo(_offset[i]!.dx, _offset[i]!.dy)
                ..lineTo(_offset[i + 1]!.dx, _offset[i + 1]!.dy);
              canvas.drawPath(_path, _painter..strokeCap = StrokeCap.round);
            } else if (_offset[i] != null && _offset[i + 1] == null) {
              canvas.drawPoints(ui.PointMode.points, [_offset[i]!],
                  _painter..strokeCap = ui.StrokeCap.round);
            }
          }
          break;
        case PaintMode.text:
          final textSpan = TextSpan(
            text: item.text,
            style: TextStyle(
              color: _painter.color,
              fontSize: 6 * _painter.strokeWidth,
              fontWeight: FontWeight.bold,
            ),
          );
          final textPainter = TextPainter(
            text: textSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          );
          textPainter.layout(minWidth: 0, maxWidth: size.width);
          final textOffset = _offset.isEmpty
              ? Offset(size.width / 2 - textPainter.width / 2,
                  size.height / 2 - textPainter.height / 2)
              : Offset(_offset[0]!.dx - textPainter.width / 2,
                  _offset[0]!.dy - textPainter.height / 2);
          textPainter.paint(canvas, textOffset);
          if (item.selected) {
            final rect = Rect.fromLTWH(textOffset.dx, textOffset.dy,
                textPainter.width, textPainter.height);
            final paint = Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2;
            final path = Path()..addRect(rect);
            canvas.drawPath(
                DrawingUtils.dashPath(path, paint.strokeWidth), paint);
          }
          break;
        default:
      }
    }

    ///Draws ongoing action on the canvas while indrag.
    if (_controller.busy) {
      final _start = _controller.start;
      final _end = _controller.end;
      final _paint = _controller.brush;
      switch (_controller.mode) {
        case PaintMode.rect:
          canvas.drawRect(Rect.fromPoints(_start!, _end!), _paint);
          break;
        case PaintMode.line:
          canvas.drawLine(_start!, _end!, _paint);
          break;
        case PaintMode.circle:
          final path = Path();
          path.addOval(Rect.fromCircle(
              center: _end!, radius: (_end - _start!).distance));
          canvas.drawPath(path, _paint);
          break;
        case PaintMode.arrow:
          DrawingUtils.drawArrow(canvas, _start!, _end!, _paint);
          break;
        case PaintMode.dashLine:
          final path = Path()
            ..moveTo(_start!.dx, _start.dy)
            ..lineTo(_end!.dx, _end.dy);
          canvas.drawPath(
              DrawingUtils.dashPath(path, _paint.strokeWidth), _paint);
          break;
        case PaintMode.freeStyle:
          final points = _controller.offsets;
          for (int i = 0; i < _controller.offsets.length - 1; i++) {
            if (points[i] != null && points[i + 1] != null) {
              canvas.drawLine(
                  Offset(points[i]!.dx, points[i]!.dy),
                  Offset(points[i + 1]!.dx, points[i + 1]!.dy),
                  _paint..strokeCap = StrokeCap.round);
            } else if (points[i] != null && points[i + 1] == null) {
              canvas.drawPoints(ui.PointMode.points,
                  [ui.Offset(points[i]!.dx, points[i]!.dy)], _paint);
            }
          }
          break;
        default:
      }
    }
  }

  @override
  bool shouldRepaint(DrawImage oldInfo) {
    return oldInfo._controller != _controller;
  }
}

///All the paint method available for use.
