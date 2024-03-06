import 'dart:collection';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:ic_scanner/data/sample.dart';

class Storage with ChangeNotifier {
  static final Storage _instance = Storage._internal();
  // static final LocalStorage _localStorage = LocalStorage("samples");

  final List<Sample> _cache = [];
  final HashSet<int> _idLookup = HashSet<int>();

  bool _isLoaded = false;

  factory Storage() {
    return _instance;
  }

  Storage._internal();

  static void loadData() {
    if (!_instance._isLoaded) {
      _instance._loadData().then((value) {});
    }
  }

  Future<void> _loadData() async {
    // todo

    _isLoaded = true;

    notifyListeners();
  }

  List<Sample> getIdentified(
      {String? keyword, HashSet<Classification>? classification}) {
    var result = _cache.where((s) => s.isIdentified).toList();

    if (classification != null && classification.isNotEmpty) {
      result.removeWhere((s) => (s.results
              .indexWhere((e) => classification.contains(e.classification)) ==
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

  void addSample(String label, Uint8List imageBytes) {
    var id = _idLookup.length;

    while (!_idLookup.add(id)) {
      id += 1;
    }

    _cache.insert(
        0, Sample(id: id, label: label, bytes: imageBytes, results: []));

    notifyListeners();
  }

  void deleteSample(int id) {
    if (_idLookup.remove(id)) {
      _cache.removeWhere((s) => s.id == id);
      notifyListeners();
    }
  }
}
