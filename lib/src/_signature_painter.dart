import 'dart:ui';

import 'package:flutter/material.dart';

import '../image_painter_rotate.dart';

class SignaturePainter extends CustomPainter {
  final Color backgroundColor;
  late ImagePainterController _controller;
  SignaturePainter({
    required ImagePainterController controller,
    required this.backgroundColor,
  }) : super(repaint: controller) {
    _controller = controller;
  }
  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawPaintHistory(canvas);
    _drawCurrentStroke(canvas);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor,
    );
  }

  void _drawPaintHistory(Canvas canvas) {
    for (final item in _controller.paintHistory) {
      if (item.mode == PaintMode.freeStyle) {
        _drawFreeStyleStroke(canvas, item.offsets, item.paint);
      }
    }
  }

  void _drawFreeStyleStroke(Canvas canvas, List<Offset?> offsets, Paint paint) {
    for (int i = 0; i < offsets.length - 1; i++) {
      _drawStrokeSegment(canvas, offsets[i], offsets[i + 1], paint);
    }
  }

  void _drawCurrentStroke(Canvas canvas) {
    if (!_controller.busy) return;

    final points = _controller.offsets;
    final paint = _controller.brush;

    for (int i = 0; i < points.length - 1; i++) {
      _drawStrokeSegment(canvas, points[i], points[i + 1], paint);
    }
  }

  void _drawStrokeSegment(
      Canvas canvas, Offset? start, Offset? end, Paint paint) {
    paint.strokeCap = StrokeCap.round;

    if (start != null && end != null) {
      canvas.drawLine(start, end, paint);
    } else if (start != null) {
      canvas.drawPoints(PointMode.points, [start], paint);
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) {
    return oldDelegate._controller != _controller;
  }
}
