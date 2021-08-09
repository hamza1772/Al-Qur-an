import 'dart:convert';

import 'package:dio/dio.dart' as Dio;
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';

import 'juz/juz_new_model.dart';

DateTime dateTime = DateTime.now();

class HttpService {
  DioCacheManager _dioCacheManager;

  Future<List<NewAyah>> getJuzAyah(String juzNumber) async {
    String url = "http://api.alquran.cloud/v1/juz/$juzNumber/ar.mahermuaiqly";
    _dioCacheManager = DioCacheManager(CacheConfig());

    Options _cacheOptions = buildCacheOptions(Duration(days: 1), maxStale: Duration(days: 10), forceRefresh: false);
    Dio.Dio _dio = Dio.Dio();
    _dio.interceptors.add(_dioCacheManager.interceptor);
    Dio.Response response = await _dio.get(url, options: _cacheOptions);
    // http.Response response = await http.get(url, headers: {'X-RapidAPI-Key': api1});
    if (response.statusCode == 200) {
      JuzNewModel juzNewModel = JuzNewModel.fromJson(response.data);;
      return juzNewModel.data.ayahs;
    } else {
      throw 'Something went wrong check your code';
    }
  }
}
