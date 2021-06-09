import 'package:dio/dio.dart';

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

  factory RequestException.create(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        {
          return BadRequestException(-1, "请求取消");
        }
      case DioErrorType.connectTimeout:
        {
          return BadRequestException(-1, "连接超时");
        }
      case DioErrorType.sendTimeout:
        {
          return BadRequestException(-1, "请求超时");
        }
      case DioErrorType.receiveTimeout:
        {
          return BadRequestException(-1, "响应超时");
        }
      case DioErrorType.response:
        {
          try {
            int errCode = error.response?.statusCode ?? -1;
            // String errMsg = error.response.statusMessage;
            // return ErrorEntity(code: errCode, message: errMsg);
            switch (errCode) {
              case 400:
                {
                  return BadRequestException(errCode, "请求语法错误");
                }
              case 401:
                {
                  return UnauthorisedException(errCode, "没有权限");
                }
              case 403:
                {
                  return UnauthorisedException(errCode, "服务器拒绝执行");
                }
              case 404:
                {
                  return UnauthorisedException(errCode, "无法连接服务器");
                }
              case 405:
                {
                  return UnauthorisedException(errCode, "请求方法被禁止");
                }
              case 500:
                {
                  return BadServiceException(errCode, "服务器内部错误");
                }
              case 502:
                {
                  return BadServiceException(errCode, "无效的请求");
                }
              case 503:
                {
                  return BadServiceException(errCode, "服务器挂了");
                }
              case 505:
                {
                  return UnauthorisedException(errCode, "不支持HTTP协议请求");
                }
              default:
                {
                  return UnknownException(
                      errCode, error.response?.statusMessage ?? '未知错误');
                }
            }
          } on Exception catch (_) {
            return UnknownException(-1, "未知错误");
          }
        }
      default:
        {
          return RequestException(-1, error.message);
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
