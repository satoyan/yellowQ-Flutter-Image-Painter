import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../image_painter_rotate.dart';
import '_signature_painter.dart';
import 'action.dart';
import 'paint_info.dart';

class ImagePainterController extends ChangeNotifier {
  late double _strokeWidth;
  late Color _color;
  late PaintMode _mode;
  late String _text;
  late bool _fill;
  late ui.Image? _image;
  Rect _rect = Rect.zero;

  final List<Offset?> _offsets = [];

  final List<PaintInfo> _paintHistory = [];
  final List<PaintAction> _actionHistory = [];
  final List<PaintAction> _undoActionHistory = [];

  Offset? _start, _end;

  int _strokeMultiplier = 1;
  bool _paintInProgress = false;
  bool _isSignature = false;

  ui.Image? get image => _image;

  Paint get brush => Paint()
    ..color = _color
    ..strokeWidth = _strokeWidth * _strokeMultiplier
    ..style = shouldFill ? PaintingStyle.fill : PaintingStyle.stroke;

  PaintMode get mode => _mode;

  double get strokeWidth => _strokeWidth;

  double get scaledStrokeWidth => _strokeWidth * _strokeMultiplier;

  bool get busy => _paintInProgress;

  bool get fill => _fill;

  Color get color => _color;

  List<PaintInfo> get paintHistory => _paintHistory;

  List<Offset?> get offsets => _offsets;

  Offset? get start => _start;

  Offset? get end => _end;

  bool get onTextUpdateMode =>
      _mode == PaintMode.text &&
      _paintHistory
          .where((element) => element.mode == PaintMode.text)
          .isNotEmpty;

  ImagePainterController({
    double strokeWidth = 4.0,
    Color color = Colors.red,
    PaintMode mode = PaintMode.freeStyle,
    String text = '',
    bool fill = false,
  }) {
    _strokeWidth = strokeWidth;
    _color = color;
    _mode = mode;
    _text = text;
    _fill = fill;
  }

  void setImage(ui.Image image) {
    _image = image;
    notifyListeners();
  }

  void setRect(Size size) {
    _rect = Rect.fromLTWH(0, 0, size.width, size.height);
    _isSignature = true;
    notifyListeners();
  }

  void addPaintInfo(PaintInfo paintInfo) {
    _paintHistory.add(paintInfo);
    _actionHistory.add(AddAction(paintInfo));
    notifyListeners();
  }

  void addMoveAction(PaintInfo paintInfo, List<Offset?> oldOffsets) {
    _actionHistory.add(MoveAction(paintInfo, oldOffsets, paintInfo.offsets));
    notifyListeners();
  }

  void updatePaintInfo(PaintInfo paintInfo) {
    final index = _paintHistory.indexOf(paintInfo);
    if (index != -1) {
      _paintHistory[index] = paintInfo;
      notifyListeners();
    }
  }

  void undo() {
    if (_actionHistory.isNotEmpty) {
      final lastAction = _actionHistory.removeLast();
      lastAction.undo(_paintHistory);
      _undoActionHistory.add(lastAction);
      notifyListeners();
    }
  }

  void redo() {
    if (_undoActionHistory.isNotEmpty) {
      final lastAction = _undoActionHistory.removeLast();
      lastAction.redo(_paintHistory);
      _actionHistory.add(lastAction);
      notifyListeners();
    }
  }

  void clear() {
    if (_paintHistory.isNotEmpty) {
      _paintHistory.clear();
      _actionHistory.clear();
      _undoActionHistory.clear();
      notifyListeners();
    }
  }

  void setStrokeWidth(double val) {
    _strokeWidth = val;
    notifyListeners();
  }

  void setColor(Color color) {
    _color = color;
    notifyListeners();
  }

  void setMode(PaintMode mode) {
    _mode = mode;
    if (_mode == PaintMode.freeStyle) {
      _offsets.clear();
    }
    notifyListeners();
  }

  void setText(String val) {
    _text = val;
    notifyListeners();
  }

  void addOffsets(Offset? offset) {
    _offsets.add(offset);
    notifyListeners();
  }

  void setStart(Offset? offset) {
    _start = offset;
    notifyListeners();
  }

  void setEnd(Offset? offset) {
    _end = offset;
    notifyListeners();
  }

  void resetStartAndEnd() {
    _start = null;
    _end = null;
    notifyListeners();
  }

  void update({
    double? strokeWidth,
    Color? color,
    bool? fill,
    PaintMode? mode,
    String? text,
    int? strokeMultiplier,
  }) {
    _strokeWidth = strokeWidth ?? _strokeWidth;
    _color = color ?? _color;
    _fill = fill ?? _fill;
    _mode = mode ?? _mode;
    _text = text ?? _text;
    _strokeMultiplier = strokeMultiplier ?? _strokeMultiplier;
    notifyListeners();
  }

  void setInProgress(bool val) {
    _paintInProgress = val;
    notifyListeners();
  }

  void deselectAll() {
    for (final item in _paintHistory) {
      item.selected = false;
    }
    notifyListeners();
  }

  PaintInfo? detectObject(Offset offset) {
    for (final item in _paintHistory) {
      item.selected = false;
    }
    for (final item in _paintHistory.reversed) {
      if (item.mode == PaintMode.rect) {
        final rect = Rect.fromPoints(item.offsets[0]!, item.offsets[1]!);
        if (rect.contains(offset)) {
          item.selected = true;
          notifyListeners();
          return item;
        }
      } else if (item.mode == PaintMode.line) {
        final p1 = item.offsets[0]!;
        final p2 = item.offsets[1]!;
        final distance = ((p2.dx - p1.dx) * (p1.dy - offset.dy) -
                    (p1.dx - offset.dx) * (p2.dy - p1.dy))
                .abs() /
            (p2 - p1).distance;
        if (distance < 10) {
          item.selected = true;
          notifyListeners();
          return item;
        }
      } else if (item.mode == PaintMode.circle) {
        final center = item.offsets[1]!;
        final radius = (item.offsets[0]! - item.offsets[1]!).distance;
        if ((offset - center).distance < radius) {
          item.selected = true;
          notifyListeners();
          return item;
        }
      } else if (item.mode == PaintMode.arrow) {
        final p1 = item.offsets[0]!;
        final p2 = item.offsets[1]!;
        final distance = ((p2.dx - p1.dx) * (p1.dy - offset.dy) -
                    (p1.dx - offset.dx) * (p2.dy - p1.dy))
                .abs() /
            (p2 - p1).distance;
        if (distance < 10) {
          item.selected = true;
          notifyListeners();
          return item;
        }
      } else if (item.mode == PaintMode.dashLine) {
        final p1 = item.offsets[0]!;
        final p2 = item.offsets[1]!;
        final distance = ((p2.dx - p1.dx) * (p1.dy - offset.dy) -
                    (p1.dx - offset.dx) * (p2.dy - p1.dy))
                .abs() /
            (p2 - p1).distance;
        if (distance < 10) {
          item.selected = true;
          notifyListeners();
          return item;
        }
      } else if (item.mode == PaintMode.text) {
        final textSpan = TextSpan(
          text: item.text,
          style: TextStyle(
            color: item.color,
            fontSize: 6 * item.strokeWidth,
            fontWeight: FontWeight.bold,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(minWidth: 0, maxWidth: double.infinity);
        final textOffset = item.offsets.isEmpty
            ? Offset(-textPainter.width / 2, -textPainter.height / 2)
            : Offset(item.offsets[0]!.dx - textPainter.width / 2,
                item.offsets[0]!.dy - textPainter.height / 2);
        final rect = Rect.fromLTWH(textOffset.dx, textOffset.dy,
            textPainter.width, textPainter.height);
        if (rect.contains(offset)) {
          item.selected = true;
          notifyListeners();
          return item;
        }
      }
    }
    return null;
  }

  bool get shouldFill {
    if (mode == PaintMode.circle || mode == PaintMode.rect) {
      return _fill;
    } else {
      return false;
    }
  }

  /// Generates [Uint8List] of the [ui.Image] generated by the [renderImage()] method.
  /// Can be converted to image file by writing as bytes.
  Future<Uint8List?> _renderImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final painter = DrawImage(controller: this);
    final size = Size(_image!.width.toDouble(), _image!.height.toDouble());
    painter.paint(canvas, size);
    final _convertedImage = await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
    final byteData =
        await _convertedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<Uint8List?> _renderSignature() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    SignaturePainter painter =
        SignaturePainter(controller: this, backgroundColor: Colors.blue);

    Size size = Size(_rect.width, _rect.height);

    painter.paint(canvas, size);
    final _convertedImage = await recorder
        .endRecording()
        .toImage(size.width.floor(), size.height.floor());
    final byteData =
        await _convertedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<Uint8List?> exportImage() {
    if (_isSignature) {
      return _renderSignature();
    } else {
      return _renderImage();
    }
  }
}

extension ControllerExt on ImagePainterController {
  bool canFill() {
    return mode == PaintMode.circle || mode == PaintMode.rect;
  }
}
