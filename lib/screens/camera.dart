import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ic_scanner/main.dart';
import 'package:ic_scanner/screens/cropper.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CameraScreen extends StatefulWidget {
  final VoidCallback refreshItems;

  const CameraScreen({super.key, required this.refreshItems});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  Uint8List? _data;
  String? _label;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.setFlashMode(FlashMode.off);
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  // void openCrop() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {

  //     widget.refreshItems();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(
          child: SizedBox(
              width: 128, height: 128, child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                CameraPreview(controller),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: const Icon(PhosphorIconsFill.arrowLeft),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.white30,
                  child: Icon(
                    controller.value.flashMode == FlashMode.off
                        ? Icons.flash_off
                        : Icons.flash_on,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Toggle flash
                    setState(() {
                      controller.setFlashMode(
                        controller.value.flashMode == FlashMode.off
                            ? FlashMode.torch
                            : FlashMode.off,
                      );
                    });
                  },
                ),
                FloatingActionButton(
                  onPressed: () {
                    controller.takePicture().then((xfile) {
                      _label = xfile.name;
                      xfile.readAsBytes().then((bytes) {
                        _data = bytes;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CropperScreen(
                                image: _data!,
                                label: _label!,
                                refresh: widget.refreshItems),
                          ),
                        );
                      });
                    });
                  },
                  child: const Icon(
                    PhosphorIconsFill.aperture,
                    color: Colors.white,
                  ),
                ),
                const SizedBox.square(dimension: 32)
              ],
            ),
          )
        ],
      ),
    );
  }
}
