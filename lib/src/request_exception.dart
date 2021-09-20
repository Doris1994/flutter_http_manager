import 'package:dio/dio.dart';

/// Text delegate that exception text in widgets.
class ExceptionTextDelegate {
  String get requestCancel => 'Request Cancel';
  String get connectTimeOut => 'Connect Timeout';
  String get sendTimeOut => 'Send Timeout';
  String get receiveTimeOut => 'Reveive Timeout';
  String get errorCode400 => 'Bad Request';
  String get errorCode401 => 'Unauthorized';
  String get errorCode403 => 'Server Rejected Request';
  String get errorCode404 => 'Not Found';
  String get errorCode405 => 'Method Disabled';
  String get errorCode500 => 'Server Internal Error';
  String get errorCode502 => 'Fault Gateway';
  String get errorCode503 => 'Service is not available';
  String get errorCode505 => 'Unsupported HTTP version';
  String get unknownError => 'Unknown Error';
}

/// 自定义异常
class RequestException implements Exception {
  final String? _message;
  String get message => _message ?? this.runtimeType.toString();
  final int? _code;
  int get code => _code ?? -1;

  RequestException([this._code, this._message]);

  String toString() {
    return "code: $_code---message: $_message";
  }

  factory RequestException.create(
      DioError error, ExceptionTextDelegate textDelegate) {
    switch (error.type) {
      case DioErrorType.cancel:
        {
          return BadRequestException(-1, textDelegate.requestCancel);
        }
      case DioErrorType.connectTimeout:
        {
          return BadRequestException(-1, textDelegate.connectTimeOut);
        }
      case DioErrorType.sendTimeout:
        {
          return BadRequestException(-1, textDelegate.sendTimeOut);
        }
      case DioErrorType.receiveTimeout:
        {
          return BadRequestException(-1, textDelegate.receiveTimeOut);
        }
      case DioErrorType.response:
        {
          try {
            int errCode = error.response?.statusCode ?? -1;
            switch (errCode) {
              case 400:
                {
                  return BadRequestException(
                      errCode, textDelegate.errorCode400);
                }
              case 401:
                {
                  return UnauthorisedException(
                      errCode, textDelegate.errorCode401);
                }
              case 403:
                {
                  return UnauthorisedException(
                      errCode, textDelegate.errorCode403);
                }
              case 404:
                {
                  return UnauthorisedException(
                      errCode, textDelegate.errorCode404);
                }
              case 405:
                {
                  return UnauthorisedException(
                      errCode, textDelegate.errorCode405);
                }
              case 500:
                {
                  return BadServiceException(
                      errCode, textDelegate.errorCode500);
                }
              case 502:
                {
                  return BadServiceException(
                      errCode, textDelegate.errorCode502);
                }
              case 503:
                {
                  return BadServiceException(
                      errCode, textDelegate.errorCode503);
                }
              default:
                {
                  return UnknownException(
                      errCode,
                      error.response?.statusMessage ??
                          textDelegate.unknownError);
                }
            }
          } on Exception catch (_) {
            return UnknownException(-1, textDelegate.unknownError);
          }
        }
      default:
        {
          return UnknownException(-1, error.message);
        }
    }
  }
}

/// 客户端请求错误
class BadRequestException extends RequestException {
  BadRequestException(int code, String message) : super(code, message);
}

/// 服务端响应错误
class BadServiceException extends RequestException {
  BadServiceException(int code, String message) : super(code, message);
}

/// 未认证异常
class UnauthorisedException extends RequestException {
  UnauthorisedException(int code, String message) : super(code, message);
}

class UnknownException extends RequestException {
  UnknownException(int code, String message) : super(code, message);
}
