import 'dart:typed_data';
import 'dart:ui';

class Sample {
  final int id;
  final String label;
  final Uint8List bytes;
  List<Result> results;
  bool inferring;

  Sample(
      {required this.id,
      required this.label,
      required this.bytes,
      required this.results,
      this.inferring = false});

  bool get isPending => results.isEmpty;
  bool get isIdentified => results.isNotEmpty;
}

class Result {
  final Classification classification;

  final int x;
  final int y;
  final int width;
  final int height;
  final double probability;

  Result({
    required this.classification,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.probability,
  });

  static Result fromJson(Map<String, dynamic> json) {
    double x1 = json['x1'];
    double y1 = json['y1'];
    double x2 = json['x2'];
    double y2 = json['y2'];

    return Result(
      x: x1.toInt(),
      y: y1.toInt(),
      width: (x2 - x1).toInt(),
      height: (y2 - y1).toInt(),
      probability: json['probability'],
      classification: classFromApi(json['classification']),
    );
  }
}

enum Classification {
  normal,
  incipient,
  mature,
  hypermature,
}

Classification classFromApi(String value) {
  switch (value) {
    case "Hypermature":
      return Classification.hypermature;
    case "Normal":
      return Classification.normal;
    case "Incipient":
      return Classification.incipient;
    case "Mature":
      return Classification.mature;
    default:
      throw "Invalid classification";
  }
}

extension ClassificationUi on Classification {
  Color get color {
    switch (this) {
      case Classification.hypermature:
        return const Color(0xffe84037);
      case Classification.normal:
        return const Color(0xff2f6df6);
      case Classification.incipient:
        return const Color(0xffee712f);
      case Classification.mature:
        return const Color(0xffe543cc);
      default:
        return const Color(0x00000000);
    }
  }

  String get label {
    switch (this) {
      case Classification.hypermature:
        return "hypermature";
      case Classification.normal:
        return "normal";
      case Classification.incipient:
        return "incipient";
      case Classification.mature:
        return "mature";
      default:
        return "";
    }
  }
}
