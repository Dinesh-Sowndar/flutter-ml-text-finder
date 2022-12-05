import 'dart:io';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognizerPainter extends CustomPainter {
  TextRecognizerPainter(
      this.text, this.recognizedText, this.absoluteImageSize, this.rotation);

  final String text;
  final RecognizedText recognizedText;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.red;

    final Paint background = Paint()..color = Color(0x99000000);

    for (final textBlocks in recognizedText.blocks) {
      for (final line in textBlocks.lines) {
        for (final element in line.elements) {
          final ParagraphBuilder builder = ParagraphBuilder(
            ParagraphStyle(
                textAlign: TextAlign.left,
                fontSize: 16,
                textDirection: TextDirection.ltr),
          );
          builder.pushStyle(
              ui.TextStyle(color: Colors.red, background: background));
          builder.addText(element.text);
          builder.pop();

          final left = translateX(
              element.boundingBox.left, rotation, size, absoluteImageSize);
          final top = translateY(
              element.boundingBox.top, rotation, size, absoluteImageSize);
          final right = translateX(
              element.boundingBox.right, rotation, size, absoluteImageSize);
          final bottom = translateY(
              element.boundingBox.bottom, rotation, size, absoluteImageSize);

          if (element.text.toLowerCase().contains(text.toLowerCase())) {
            canvas.drawRect(
              Rect.fromLTRB(left, top, right, bottom),
              paint,
            );

            canvas.drawParagraph(
              builder.build()
                ..layout(ParagraphConstraints(
                  width: right - left,
                )),
              Offset(left, top),
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(TextRecognizerPainter oldDelegate) {
    return oldDelegate.recognizedText != recognizedText;
  }
}

double translateX(
    double x, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
      return x *
          size.width /
          (Platform.isIOS ? absoluteImageSize.width : absoluteImageSize.height);
    case InputImageRotation.rotation270deg:
      return size.width -
          x *
              size.width /
              (Platform.isIOS
                  ? absoluteImageSize.width
                  : absoluteImageSize.height);
    default:
      return x * size.width / absoluteImageSize.width;
  }
}

double translateY(
    double y, InputImageRotation rotation, Size size, Size absoluteImageSize) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          size.height /
          (Platform.isIOS ? absoluteImageSize.height : absoluteImageSize.width);
    default:
      return y * size.height / absoluteImageSize.height;
  }
}
