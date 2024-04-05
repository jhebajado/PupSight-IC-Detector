import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ic_scanner/data/sample.dart';
import 'package:localstorage/localstorage.dart';

class Storage with ChangeNotifier {
  static final Storage _instance = Storage._internal();
  static final LocalStorage _localStorage = LocalStorage("samples");

  List<Sample> _cache = [];
  bool isLoaded = false;

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  static void loadData() {
    if (!_instance.isLoaded) {
      _instance._loadData().then((value) {});
    }
  }

  Future<void> _loadData() async {
    final myUri = Uri.parse("/home/ferrox/Pictures/New Folder (2)/normal4.jpg");
    final image = File.fromUri(myUri);
    final bytes = await image.readAsBytes();

    _cache = [
      Sample(label: "Super eyes", bytes: bytes, results: [
        Result(
            classification: Classification.hypermature,
            x: 128,
            y: 128,
            width: 328,
            height: 264)
      ]),
      Sample(label: "Super eyes1", bytes: bytes, results: [
        Result(
            classification: Classification.normal,
            x: 128,
            y: 128,
            width: 328,
            height: 264)
      ]),
      Sample(label: "Super 12", bytes: bytes, results: [
        Result(
            classification: Classification.mature,
            x: 128,
            y: 128,
            width: 328,
            height: 264),
        Result(
            classification: Classification.incipient,
            x: 180,
            y: 96,
            width: 328,
            height: 264)
      ]),
      Sample(label: "Super eyes2", bytes: bytes, inferring: true, results: []),
      Sample(label: "Super eyes2", bytes: bytes, results: [])
    ];

    isLoaded = true;

    notifyListeners();
  }

  List<Sample> getIdentified(
      {String? keyword, Classification? classification}) {
    var result = _cache.where((s) => s.isIdentified).toList();

    if (classification != null) {
      result.removeWhere((s) =>
          (s.results.indexWhere((e) => e.classification == classification) ==
              -1));
    }

    if (keyword != null) {
      result.removeWhere(
          (s) => !s.label.toLowerCase().contains(keyword.toLowerCase()));
    }

    return result;
  }

  List<Sample> getPendings({String? keyword}) {
    var result = _cache.where((s) => s.isPending).toList();

    if (keyword != null) {
      result.removeWhere(
          (s) => !s.label.toLowerCase().contains(keyword.toLowerCase()));
    }

    return result;
  }
}
