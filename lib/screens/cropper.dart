import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:ic_scanner/data/storage.dart';

class CropperScreen extends StatefulWidget {
  final Uint8List image;
  final String label;
  final VoidCallback refresh;

  const CropperScreen(
      {super.key,
      required this.image,
      required this.label,
      required this.refresh});

  @override
  // ignore: library_private_types_in_public_api
  _CropperScreenState createState() => _CropperScreenState();
}

class _CropperScreenState extends State<CropperScreen> {
  final _controller = CropController();
  final storage = Storage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Cropper'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Crop(
        image: widget.image, // Replace _imageData with your actual image data
        controller: _controller,
        onCropped: (imageBytes) {
          storage.addSample(widget.label, imageBytes);
          widget.refresh();
        },
        aspectRatio: 1,
        initialRectBuilder: (rect, _) {
          double size = rect.width < rect.height ? rect.width : rect.height;
          double centerX = rect.left + rect.width / 2;
          double centerY = rect.top + rect.height / 2;
          double halfSize = size / 2;
          return Rect.fromLTRB(
            centerX - halfSize,
            centerY - halfSize,
            centerX + halfSize,
            centerY + halfSize,
          );
        },
        // withCircleUi: true,
        baseColor: Colors.blue.shade900,
        maskColor: Colors.white.withAlpha(100),
        progressIndicator: const CircularProgressIndicator(),
        radius: 20,
        onMoved: (newRect) {
          // do something with current crop rect.
        },
        onStatusChanged: (status) {
          // do something with current CropStatus
        },
        willUpdateScale: (newScale) {
          // if returning false, scaling will be canceled
          return newScale < 5;
        },
        cornerDotBuilder: (size, edgeAlignment) =>
            const DotControl(color: Colors.blue),
        clipBehavior: Clip.none,
        interactive: true,
        // fixCropRect: true,
        // formatDetector: (image) {},
        // imageCropper: myCustomImageCropper,
        // imageParser: (image, {format}) {},
      ),
    );
  }
}
