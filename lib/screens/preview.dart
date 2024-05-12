import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ic_scanner/api.dart';
import 'package:ic_scanner/data/sample.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class SamplePreview extends StatelessWidget {
  final Sample sample;
  final VoidCallback deleteSample;

  const SamplePreview({
    super.key,
    required this.sample,
    required this.deleteSample,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(sample.label),
          actions: [
            IconButton(
              onPressed: () {
                deleteSample();
              },
              icon: const Icon(PhosphorIconsFill.trash),
            )
          ],
        ),
        body: LayoutBuilder(builder: (context, box) {
          final annotationScale =
              Point(box.maxWidth / 640, box.maxHeight / 640);

          return Stack(
            children: [
              Image.network(
                getSampleUrl(sample.id),
                fit: BoxFit.fitWidth,
                width: box.maxWidth,
                height: box.maxHeight,
              ),
              if (sample.isIdentified)
                ...sample.results.map((result) => Positioned(
                      left: result.x.toDouble() * annotationScale.x,
                      top: box.maxHeight * 0.5 -
                          result.y.toDouble() * annotationScale.y,
                      child: Stack(
                        children: [
                          Container(
                            height:
                                result.height.toDouble() * annotationScale.x,
                            width: result.width.toDouble() * annotationScale.y,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: result.isNormal
                                      ? Colors.blueAccent
                                      : Colors.redAccent,
                                  width: 4,
                                )),
                          ),
                          if (!result.isNormal) ...[
                            Positioned(
                              left: 12,
                              top: 12,
                              child: Text(
                                'INCIPIENT\nX: ${result.x + result.width / 2}\nY: ${result.y + result.height / 2}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          ] else ...[
                            const Positioned(
                              left: 12,
                              top: 12,
                              child: Text(
                                'NORMAL',
                                style: TextStyle(color: Colors.white),
                              ),
                            )
                          ]
                        ],
                      ),
                    )),
            ],
          );
        }));
  }
}

class ClassificationCard extends StatelessWidget {
  final bool isNormal;

  const ClassificationCard({
    super.key,
    required this.isNormal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isNormal ? Colors.blueAccent : Colors.redAccent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          isNormal ? "Normal" : "Incipient",
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
