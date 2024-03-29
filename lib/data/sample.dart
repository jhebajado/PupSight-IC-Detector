class Sample {
  final String id;
  final String label;
  final List<Result> results;
  bool inferring;

  Sample(
      {required this.id,
      required this.label,
      required this.results,
      this.inferring = false});

  bool get isPending => results.isEmpty;
  bool get isIdentified => results.isNotEmpty;
}

class Result {
  final String id;
  final String certainty;
  final bool isNormal;
  final int x;
  final int y;
  final int width;
  final int height;

  Result({
    required this.id,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.certainty,
    required this.isNormal,
  });

  static Result fromJson(Map<String, dynamic> json) {
    double x = json['x'];
    double y = json['y'];
    double width = json['width'];
    double height = json['height'];

    return Result(
      id: json["id"],
      x: x.toInt(),
      y: y.toInt(),
      width: width.toInt(),
      height: height.toInt(),
      certainty: json['certainty'],
      isNormal: json['is_normal'],
    );
  }
}
