import 'package:dio/dio.dart';
import 'request_exception.dart';
import 'request_manager.dart';

enum HttpRequestMethod { get, post, put, head, delete, patch }
enum HttpRequestStatus { unknown, running, finished, canceled }

typedef SuccessCallback = void Function(dynamic value);
typedef FailureCallback = void Function(RequestException exception);

abstract class BaseHttpRequest {
  final String path;
  final HttpRequestMethod method;
  int sendTimeout = 3000;
  int receiveTimeout = 3000;
  int connectTimeout = 5000;
  SuccessCallback? _successCallback;
  FailureCallback? _failureCallback;
  ProgressCallback? _progressCallback;

  final token = CancelToken();

  HttpRequestStatus status = HttpRequestStatus.unknown;

  BaseHttpRequest(this.path, {this.method = HttpRequestMethod.get});

  String get baseUrl;

  Map<String, dynamic> get headers => {};
  Map<String, dynamic>? get parameters;

  //SuccessCallback? get successCallback => _successCallback;
  //FailureCallback? get failureCallback => _failureCallback;
  ProgressCallback? get progressCallback => _progressCallback;

  void _start() {
    if (status == HttpRequestStatus.running) return;
    if (baseUrl.isEmpty) return;
    RequestManager().addRequest(this);
    status = HttpRequestStatus.running;
  }

  void startWithResultHandler(
      {SuccessCallback? success, FailureCallback? failure}) {
    _successCallback = success;
    _failureCallback = failure;
    _start();
  }

  void didFinishSuccess(dynamic value) {
    _successCallback?.call(value);
  }

  void didFinishFailure(RequestException error) {
    _failureCallback?.call(error);
  }

  void cancel() {
    if (status == HttpRequestStatus.running) {
      // cancel the requests with "cancelled" message.
      token.cancel("cancelled");
    }
  }
}
