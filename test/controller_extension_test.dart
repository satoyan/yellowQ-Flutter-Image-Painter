import 'package:flutter_test/flutter_test.dart';
import 'package:image_painter_rotate/image_painter_rotate.dart';

void main() {
  group('ControllerExt', () {
    test('canFill() should return true for circle mode', () {
      final controller = ImagePainterController(mode: PaintMode.circle);
      expect(controller.canFill(), isTrue);
    });

    test('canFill() should return true for rect mode', () {
      final controller = ImagePainterController(mode: PaintMode.rect);
      expect(controller.canFill(), isTrue);
    });

    test('canFill() should return false for freeStyle mode', () {
      final controller = ImagePainterController(mode: PaintMode.freeStyle);
      expect(controller.canFill(), isFalse);
    });

    test('canFill() should return false for line mode', () {
      final controller = ImagePainterController(mode: PaintMode.line);
      expect(controller.canFill(), isFalse);
    });

    test('canFill() should return false for text mode', () {
      final controller = ImagePainterController(mode: PaintMode.text);
      expect(controller.canFill(), isFalse);
    });

    test('canFill() should return false for arrow mode', () {
      final controller = ImagePainterController(mode: PaintMode.arrow);
      expect(controller.canFill(), isFalse);
    });

    test('canFill() should return false for dashLine mode', () {
      final controller = ImagePainterController(mode: PaintMode.dashLine);
      expect(controller.canFill(), isFalse);
    });
  });
}
