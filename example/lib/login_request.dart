import 'package:flutter_http_manager/flutter_http_manager.dart';

class LoginRequest extends BaseHttpRequest
{
  LoginRequest() : super('path',method: HttpRequestMethod.post);

  @override
  String get baseUrl => '';
 
}