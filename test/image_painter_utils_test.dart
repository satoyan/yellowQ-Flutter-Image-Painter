import 'dart:ui' as ui;

import 'package:flutter/material.dart' hide Image;
import 'package:flutter_test/flutter_test.dart';
import 'package:image_painter_rotate/src/drawing_utils.dart'; // Import DrawingUtils

import 'test_canvas.dart'; // Import the custom TestCanvas

void main() {
  group('DrawingUtils', () {
    late TestCanvas testCanvas;
    late ui.Paint realPaint;

    setUp(() {
      testCanvas = TestCanvas();
      realPaint = ui.Paint()
        ..color = Colors.black
        ..strokeWidth = 10.0
        ..style = ui.PaintingStyle.stroke;
    });

    test('drawArrow should draw a line and an arrowhead', () {
      const start = ui.Offset(0, 0);
      const end = ui.Offset(100, 0);

      DrawingUtils.drawArrow(testCanvas, start, end, realPaint);

      // Verify that drawLine is called
      expect(
          testCanvas.invocations.any((invocation) =>
              invocation.memberName == #drawLine &&
              invocation.positionalArguments[0] == start &&
              invocation.positionalArguments[1] == end &&
              invocation.positionalArguments[2] == realPaint),
          isTrue);

      // Verify that save, translate, rotate, drawPath, and restore are called
      expect(
          testCanvas.invocations
              .any((invocation) => invocation.memberName == #save),
          isTrue);
      expect(
          testCanvas.invocations.any((invocation) =>
              invocation.memberName == #translate &&
              invocation.positionalArguments[0] == end.dx &&
              invocation.positionalArguments[1] == end.dy),
          isTrue);
      expect(
          testCanvas.invocations.any((invocation) =>
              invocation.memberName == #rotate &&
              (invocation.positionalArguments[0] as double).abs() <
                  0.001), // Check for a rotation value close to 0
          isTrue);
      expect(
          testCanvas.invocations.any((invocation) =>
              invocation.memberName == #drawPath &&
              invocation.positionalArguments[0] is ui.Path &&
              invocation.positionalArguments[1] is ui.Paint),
          isTrue);
      expect(
          testCanvas.invocations
              .any((invocation) => invocation.memberName == #restore),
          isTrue);
    });

    test('dashPath should create a dashed path', () {
      final path = ui.Path()
        ..moveTo(0, 0)
        ..lineTo(100, 0);
      const strokeWidth = 5.0;

      final dashedPath = DrawingUtils.dashPath(path, strokeWidth);

      // Verify that the dashed path is not empty
      expect(dashedPath, isNotNull);
      expect(dashedPath.computeMetrics().isNotEmpty, isTrue);

      // Further checks could involve inspecting the path segments,
      // but that's more complex and might require custom matchers.
      // For now, checking that it's not empty and has metrics is sufficient.
    });
  });
}

