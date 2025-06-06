import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_painter_rotate/image_painter_rotate.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

class SignatureExample extends StatefulWidget {
  const SignatureExample({super.key});

  @override
  SignatureExampleState createState() => SignatureExampleState();
}

class SignatureExampleState extends State<SignatureExample> {
  final _controller = ImagePainterController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Painter Example")),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ImagePainter.signature(
            height: 200,
            width: 300,
            controller: _controller,
            signatureBgColor: Colors.grey[200],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: saveImage,
        child: const Icon(Icons.save),
      ),
    );
  }

  void saveImage() async {
    final image = await _controller.exportImage();
    final directory = (await getApplicationDocumentsDirectory()).path;
    await Directory('$directory/sample').create(recursive: true);
    final fullPath = '$directory/sample/image.png';
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
                  style: TextStyle(color: Colors.blue[200]),
                ),
              )
            ],
          ),
        ),
      );
    }
  }
}
