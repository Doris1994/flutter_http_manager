import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'request_exception.dart';

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioError err,ErrorInterceptorHandler handler) {
    // error统一处理
    RequestException exception = RequestException.create(err);
    // 错误提示
    debugPrint('DioError===: ${exception.toString()}');
    err.error = exception;
    return super.onError(err,handler);
  }
}
