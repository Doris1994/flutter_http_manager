import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio_http2_adapter/dio_http2_adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'http_request.dart';
import 'error_interceptor.dart';

class RequestManager {
  final Dio _dio = Dio();

  factory RequestManager() => _sharedInstance();

  static RequestManager? _instance;

  Interceptor? _refreshTokenInterceptor;

  RequestManager._() {
    // 具体初始化代码
    //忽略https证书验证,仅对App有效，对web无效
    /*if (_dio.httpClientAdapter.runtimeType is DefaultHttpClientAdapter) {
      (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
      };
    }*/

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(responseBody: false)); //开启请求日志
    }
    // initInterceptor(_refreshTokenInterceptor);
    if (kIsWeb) return;
    //DefaultHttpClientAdapter();
    _dio.httpClientAdapter = Http2Adapter(
      ConnectionManager(
        idleTimeout: 3000,
        // Ignore bad certificate
        onClientCreate: (_, config) => config.onBadCertificate = (_) => true,
      ),
    );
  }

  static RequestManager _sharedInstance() {
    if (_instance == null) {
      _instance = RequestManager._();
    }
    return _instance!;
  }

  void initInterceptor(Interceptor? interceptor) {
    _refreshTokenInterceptor = interceptor;
    if (_refreshTokenInterceptor != null) {
      _dio.interceptors.add(_refreshTokenInterceptor!);
    }
    _dio.interceptors.add(ErrorInterceptor());
  }

  void addRequest(BaseHttpRequest request) {
    String url = request.baseUrl + request.path;
    Map<String, dynamic> headers =
        request.headers.map((key, value) => MapEntry(key.toLowerCase(), value));
    debugPrint(headers.toString());
    Options options = Options(
        sendTimeout: request.sendTimeout,
        receiveTimeout: request.receiveTimeout,
        headers: headers);
    try {
      switch (request.method) {
        case HttpRequestMethod.get:
          {
            _dio
                .get(url,
                    queryParameters: request.parameters,
                    cancelToken: request.token,
                    onReceiveProgress: request.progressCallback,
                    options: options)
                .then((value) => _responseHandler(request, value))
                .onError((error, stackTrace) {
              if (error is DioError) {
                _errorHandler(request, error);
              }
            });
          }
          break;
        case HttpRequestMethod.post:
          {
            _dio
                .post(url,
                    data: request.parameters,
                    cancelToken: request.token,
                    onSendProgress: request.progressCallback,
                    options: options)
                .then((value) => _responseHandler(request, value))
                .onError((error, stackTrace) {
              if (error is DioError) {
                _errorHandler(request, error);
              }
            });
          }
          break;
        default:
          debugPrint('request manager not this method ===: ${request.method}');
      }
    } on DioError catch (error) {
      _errorHandler(request, error);
    }
  }

  void _errorHandler(BaseHttpRequest request, DioError error) {
    if (CancelToken.isCancel(error)) {
      print('Request canceled! ' + error.message);
      request.status = HttpRequestStatus.canceled;
    } else {
      request.status = HttpRequestStatus.finished;
    }
    request.didFinishFailure(error.error);
  }

  void _responseHandler(BaseHttpRequest request, Response<dynamic> value) {
    request.status = HttpRequestStatus.finished;
    request.didFinishSuccess(value);
  }
}
