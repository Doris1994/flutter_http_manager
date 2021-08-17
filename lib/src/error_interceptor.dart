import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'request_exception.dart';

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  final ExceptionTextDelegate delegate;

  ErrorInterceptor({required this.delegate});

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    // error统一处理
    RequestException exception = RequestException.create(err,delegate);
    // 错误提示
    debugPrint('DioError===: ${exception.toString()}');
    err.error = exception;
    handler.reject(err);
    //super.onError(err, handler);
  }
}
