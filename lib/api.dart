import 'dart:io';
import 'dart:typed_data';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:ic_scanner/data/sample.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

const _apiUrl = "http://192.168.100.4:8083";

final cookieJar = CookieJar();
final dio =
    Dio(BaseOptions(baseUrl: _apiUrl, validateStatus: (status) => true));

Future<void> prepareJar() async {
  final Directory appDocDir = await getApplicationDocumentsDirectory();
  final String appDocPath = appDocDir.path;
  final jar = PersistCookieJar(
    ignoreExpires: true,
    storage: FileStorage("$appDocPath/.cookies/"),
  );
  dio.interceptors.add(CookieManager(jar));
}

String getSampleUrl(String id) {
  return "$_apiUrl/users/image";
}

Future<Response<dynamic>> userRegister(
    {required String loginName,
    required String firstName,
    required String lastName,
    required String password}) async {
  return await dio.post("/users/register", data: {
    "login_name": loginName,
    "first_name": firstName,
    "last_name": lastName,
    "password": password
  });
}

Future<Response<dynamic>> userLogin(
    {required String loginName, required String password}) async {
  return await dio.post("/users/login",
      data: {"login_name": loginName, "password": password});
}

Future<Response<dynamic>> checkUser() async {
  return await dio.get("/users/info");
}

Future<List<Sample>> getInferred(String? keyword) async {
  final res = await dio
      .get("/samples/infers", queryParameters: {"page": 0, "keyword": keyword});
  dynamic items = res.data?.items;

  if (items == null) {
    return List.empty();
  }

  List<Sample> samples = items.map((entry) {
    return Sample(
        id: entry["id"],
        label: entry["label"],
        results: entry["result"].map((r) {
          return Result(
              id: r["id"],
              x: r["x"],
              y: r["y"],
              width: r["width"],
              height: r["height"],
              certainty: r["certainty"],
              isNormal: r["is_normal"]);
        }));
  });

  return samples;
}

Future<List<Sample>> getPendings(String? keyword) async {
  final res = await dio.get("/samples/pendings",
      queryParameters: {"page": 0, "keyword": keyword});
  dynamic items = res.data?.items;

  if (items == null) {
    return List.empty();
  }

  List<Sample> samples = items.map((entry) {
    return Sample(
        id: entry["id"], label: entry["label"], results: List.empty());
  });

  return samples;
}

Future<Response<dynamic>> uploadSample(String filename, Uint8List bytes) async {
  FormData formData = FormData.fromMap({
    "file": MultipartFile.fromBytes(bytes, filename: filename),
  });

  return await dio.post("/samples/upload", data: formData);
}

Future<Response<dynamic>> deleteSample(String id) async {
  return await dio.post("/samples/pendings", data: {"sample_id": id});
}

Future<Response<dynamic>> inferSample(String id) async {
  return await dio.post("/samples/infer", data: {"sample_id": id});
}
