import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ic_scanner/data/sample.dart';

class SampleCard extends StatelessWidget {
  final Sample sample;
  final bool? showDelete;

  const SampleCard({super.key, required this.sample, this.showDelete});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final annotationScale = Point(box.maxWidth / 640, box.maxHeight / 640);

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8.0)),
                    child: Image.memory(
                      sample.bytes,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (showDelete == true) ...[
                        IconButton.filled(
                            onPressed: () => {},
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    Color(0xffe84037))),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ))
                      ],
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          child: Text(
                            sample.label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          )),
                      if (sample.isIdentified &&
                          sample.results[0].classification !=
                              Classification.unclassified) ...[
                        ClassificationCard(
                            classification: sample.results[0].classification)
                      ]
                    ],
                  ),
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
