import 'dart:typed_data';
import 'dart:ui';

class Sample {
  final String label;
  final List<Result> results;
  final Uint8List bytes;
  final bool inferring;

  Sample(
      {required this.label,
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

  Result({
    required this.classification,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

enum Classification {
  hypermature,
  incipient,
  mature,
  normal,
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
