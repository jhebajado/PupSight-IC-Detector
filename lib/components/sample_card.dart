import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ic_scanner/data/sample.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SampleCard extends StatelessWidget {
  final Sample sample;
  final bool showDelete;
  final VoidCallback deleteSample;
  final VoidCallback? scanSample;

  const SampleCard(
      {super.key,
      required this.sample,
      required this.deleteSample,
      this.scanSample,
      this.showDelete = false});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final annotationScale = Point(box.maxWidth / 640, box.maxHeight / 640);
      final colorScheme = Theme.of(context).colorScheme;

      return Card(
        elevation: 5,
        color: Colors.white,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8.0)),
                child: Image.memory(
                  sample.bytes,
                  fit: BoxFit.fitHeight,
                  width: box.maxWidth,
                  height: box.maxHeight,
                ),
              ),
            ),
            Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: (showDelete)
                      ? IconButton.filled(
                          onPressed: () {
                            deleteSample();
                          },
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.white)),
                          icon: Icon(PhosphorIconsFill.trash,
                              color: colorScheme.error),
                        )
                      : (scanSample != null)
                          ? IconButton.filled(
                              onPressed: () {
                                if (scanSample != null) {
                                  scanSample!();
                                }
                              },
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.white)),
                              icon: Icon(PhosphorIconsFill.scan,
                                  color: colorScheme.primary),
                            )
                          : null,
                )),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      child: Text(
                        sample.label,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      )),
                  // if (sample.isIdentified &&
                  //     sample.results[0].classification !=
                  //         Classification.unclassified) ...[
                  //   ClassificationCard(
                  //       classification: sample.results[0].classification)
                  // ]
                ),
              ),
            ),
            if (sample.isIdentified)
              ...sample.results.map((result) => Positioned(
                  left: result.x.toDouble() * annotationScale.x,
                  top: result.y.toDouble() * annotationScale.y,
                  child: Container(
                    height: result.height.toDouble() * annotationScale.x,
                    width: result.width.toDouble() * annotationScale.y,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: result.classification.color,
                          width: 4,
                        )),
                  ))),
            if (sample.inferring == true)
              Center(
                  child: SizedBox(
                height: box.maxHeight * 0.5,
                width: box.maxWidth * 0.5,
                child: const CircularProgressIndicator(
                  backgroundColor: Colors.white70,
                  semanticsLabel: "Inferring",
                  strokeCap: StrokeCap.round,
                  strokeWidth: 8,
                ),
              ))
          ],
        ),
      );
    });
  }
}

class ClassificationCard extends StatelessWidget {
  final Classification classification;

  const ClassificationCard({
    super.key,
    required this.classification,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: classification.color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          classification.label,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
