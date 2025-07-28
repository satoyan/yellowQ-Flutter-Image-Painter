import 'dart:ui' as ui;

class TestCanvas implements ui.Canvas {
  final List<Invocation> invocations = [];

  @override
  void drawLine(ui.Offset p1, ui.Offset p2, ui.Paint paint) {
    invocations.add(Invocation.method(#drawLine, [p1, p2, paint]));
  }

  @override
  void drawPath(ui.Path path, ui.Paint paint) {
    invocations.add(Invocation.method(#drawPath, [path, paint]));
  }

  @override
  void save() {
    invocations.add(Invocation.method(#save, []));
  }

  @override
  void translate(double dx, double dy) {
    invocations.add(Invocation.method(#translate, [dx, dy]));
  }

  @override
  void rotate(double radians) {
    invocations.add(Invocation.method(#rotate, [radians]));
  }

  @override
  void restore() {
    invocations.add(Invocation.method(#restore, []));
  }

  // Implement other Canvas methods as needed for testing
  @override
  dynamic noSuchMethod(Invocation invocation) {
    invocations.add(invocation);
    return super.noSuchMethod(invocation);
  }
}
