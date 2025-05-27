import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_painter_rotate/image_painter_rotate.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class MobileExample extends StatefulWidget {
  const MobileExample({super.key});

  @override
  State<MobileExample> createState() => _MobileExampleState();
}

class _MobileExampleState extends State<MobileExample> {
  final ImagePainterController _controller = ImagePainterController(
    color: Colors.green,
    strokeWidth: 4,
    mode: PaintMode.line,
  );

  int quarterTurns = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Painter Rotate Example",
            style: TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: saveImage,
          )
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      quarterTurns = (quarterTurns - 1) % 4;
                    });
                  },
                  icon: Icon(Icons.rotate_left)),
              IconButton(
                onPressed: () {
                  setState(() {
                    quarterTurns = (quarterTurns + 1) % 4;
                  });
                },
                icon: Icon(Icons.rotate_right),
              ),
            ],
          ),
          Flexible(
            child: ImagePainter.asset(
              quarterTurns: quarterTurns,
              "assets/sample.png",
              controller: _controller,
              scalable: true,
              textDelegate: TextDelegate(),
              controlsAtTop: false,
            ),
          ),
        ],
      ),
    );
  }

  void saveImage() async {
    final image = await _controller.exportImage();
    final imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath = '$directory/sample/$imageName';
    final imgFile = File(fullPath);
    if (image != null) {
      imgFile.writeAsBytesSync(image);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.grey[700],
          padding: const EdgeInsets.only(left: 10),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Image Exported successfully.",
                  style: TextStyle(color: Colors.white)),
              TextButton(
                onPressed: () => OpenFile.open(fullPath),
                child: Text(
                  "Open",
                  style: TextStyle(
                    color: Colors.blue[200],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
