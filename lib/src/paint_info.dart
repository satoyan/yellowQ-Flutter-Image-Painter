import 'package:flutter/rendering.dart';

import 'paint_mode.dart';

///[PaintInfo] keeps track of a single unit of shape, whichever selected.
class PaintInfo {
  ///Mode of the paint method.
  final PaintMode mode;

  //Used to save color
  final Color color;

  //Used to store strokesize of the mode.
  final double strokeWidth;

  ///Used to save offsets.
  ///Two point in case of other shapes and list of points for [FreeStyle].
  List<Offset?> offsets;

  ///Used to save text in case of text type.
  String text;

  //To determine whether the drawn shape is filled or not.
  bool fill;

  //To determine whether the drawn shape is selected or not.
  bool selected;

  Paint get paint => Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = shouldFill ? PaintingStyle.fill : PaintingStyle.stroke;

  bool get shouldFill {
    if (mode == PaintMode.circle || mode == PaintMode.rect) {
      return fill;
    } else {
      return false;
    }
  }

  ///In case of string, it is used to save string value entered.
  PaintInfo({
    required this.mode,
    required this.offsets,
    required this.color,
    required this.strokeWidth,
    this.text = '',
    this.fill = false,
    this.selected = false,
  });

  PaintInfo clone() {
    return PaintInfo(
      mode: mode,
      offsets: List.from(offsets),
      color: color,
      strokeWidth: strokeWidth,
      text: text,
      fill: fill,
      selected: selected,
    );
  }
}
