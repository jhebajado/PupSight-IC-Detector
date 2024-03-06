import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:ic_scanner/data/sample.dart';

const _apiUrl = "http://192.168.100.4:8083";

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

  Future<void> inferSample(int id) async {
    var url = Uri.parse('$_apiUrl/scan');
    var request = http.MultipartRequest('POST', url);
    var item = _cache.firstWhere((s) => s.id == id);
    request.files.add(
      http.MultipartFile.fromBytes('image', item.bytes, filename: item.label),
    );

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        final items = jsonDecode(utf8.decode(await response.stream.toBytes()))
            as List<dynamic>;

        final index = _cache.indexWhere((s) => s.id == id);

        if (index >= 0) {
          _cache[index].results = items.map((e) => Result.fromJson(e)).toList();
          _cache[index].inferring = false;
        }
      } else {
        throw ('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Error uploading image: $e');
    }
  }
}
