import 'package:flutter_http_manager/flutter_http_manager.dart';

class LoginRequest extends BaseHttpRequest {
  @override
  String get baseUrl => '';

  @override
  Map<String, dynamic>? get parameters => null;

  @override
  String get path => throw UnimplementedError();
}
