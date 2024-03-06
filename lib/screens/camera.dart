import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:ic_scanner/data/storage.dart';
import 'package:ic_scanner/main.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final VoidCallback refreshItems;

  const CameraScreen({super.key, required this.refreshItems});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  final Storage storage = Storage();

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
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

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(
          child: SizedBox(
              width: 128, height: 128, child: CircularProgressIndicator()));
    }

    return SafeArea(
      child: CameraPreview(controller,
          child: Stack(
            children: [
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
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                  child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runAlignment: WrapAlignment.center,
                      alignment: WrapAlignment.center,
                      spacing: 32,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            controller.takePicture().then((value) async {
                              final bytes = await value.readAsBytes();

                              storage.addSample(value.name, bytes);
                            }).whenComplete(() {
                              widget.refreshItems();

                              Navigator.of(context).pop();
                            });
                          },
                          child: const Icon(
                            PhosphorIconsFill.aperture,
                            color: Colors.white,
                          ),
                        )
                      ]),
                ),
              ),
            ],
          )),
    );
  }
}
