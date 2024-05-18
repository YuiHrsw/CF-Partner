// import 'package:cf_partner/backend/storage.dart';
import 'dart:io';

import 'package:dio/dio.dart';

class WebHelper {
  static late final Dio dio;
  static late final HttpClient fucker;
  CancelToken _cancelToken = CancelToken();

  static final WebHelper _instance = WebHelper._internal();
  factory WebHelper() => _instance;
  WebHelper._internal() {
    BaseOptions options = BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );
    dio = Dio(options);
    dio.transformer = BackgroundTransformer();
  }

  get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  post(
    String path, {
    Map<String, dynamic>? queryParameters,
    data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    var response = await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken ?? _cancelToken,
    );
    return response;
  }

  download(urlPath, savePath) async {
    Response response;
    response = await dio.download(urlPath, savePath,
        onReceiveProgress: (int count, int total) {});
    return response.data;
  }

  void cancel({required CancelToken token}) {
    _cancelToken.cancel("cancelled");
    _cancelToken = token;
  }
}
