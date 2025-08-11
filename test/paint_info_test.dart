import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/src/paint_info.dart';
import '../lib/src/paint_mode.dart';

void main() {
  group('PaintInfo', () {
    test('constructor assigns values correctly', () {
      final paintInfo = PaintInfo(
        mode: PaintMode.line,
        offsets: [const Offset(10, 20), const Offset(30, 40)],
        color: Colors.red,
        strokeWidth: 5.0,
        text: 'test',
        fill: true,
      );

      expect(paintInfo.mode, PaintMode.line);
      expect(paintInfo.offsets, [const Offset(10, 20), const Offset(30, 40)]);
      expect(paintInfo.color.value, Colors.red.value);
      expect(paintInfo.strokeWidth, 5.0);
      expect(paintInfo.text, 'test');
      expect(paintInfo.fill, true);
    });

    test('paint getter returns correct Paint object', () {
      final paintInfo = PaintInfo(
        mode: PaintMode.line,
        offsets: [],
        color: Colors.blue,
        strokeWidth: 3.0,
      );

      final paint = paintInfo.paint;

      expect(paint.color.value, Colors.blue.value);
      expect(paint.strokeWidth, 3.0);
      expect(paint.style, PaintingStyle.stroke);
    });

    test('shouldFill returns true for circle and rect when fill is true', () {
      final circlePaintInfo = PaintInfo(
        mode: PaintMode.circle,
        offsets: [],
        color: Colors.black,
        strokeWidth: 1.0,
        fill: true,
      );

      final rectPaintInfo = PaintInfo(
        mode: PaintMode.rect,
        offsets: [],
        color: Colors.black,
        strokeWidth: 1.0,
        fill: true,
      );

      expect(circlePaintInfo.shouldFill, isTrue);
      expect(rectPaintInfo.shouldFill, isTrue);
    });

    test('shouldFill returns false for other modes even when fill is true', () {
      final linePaintInfo = PaintInfo(
        mode: PaintMode.line,
        offsets: [],
        color: Colors.black,
        strokeWidth: 1.0,
        fill: true,
      );

      expect(linePaintInfo.shouldFill, isFalse);
    });

    test('clone creates a new instance with the same values', () {
      final original = PaintInfo(
        mode: PaintMode.rect,
        offsets: [const Offset(1, 2)],
        color: Colors.green,
        strokeWidth: 10.0,
        text: 'clone test',
        fill: true,
      );

      final clone = original.clone();

      expect(clone.mode, original.mode);
      expect(clone.offsets, original.offsets);
      expect(clone.color.value, original.color.value);
      expect(clone.strokeWidth, original.strokeWidth);
      expect(clone.text, original.text);
      expect(clone.fill, original.fill);
      expect(clone, isNot(same(original)));
    });
  });
}