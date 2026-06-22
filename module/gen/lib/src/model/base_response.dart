class BaseResponse<T> {
  BaseResponse({
    required this.response,
    this.data,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic)? fromJsonT,
  ]) {
    return BaseResponse<T>(
      response: ResponseInfo.fromJson(json['response'] as Map<String, dynamic>),
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
    );
  }

  final ResponseInfo response;
  final T? data;

  Map<String, dynamic> toJson([Map<String, dynamic> Function(T)? toJsonT]) {
    return {
      'response': response.toJson(),
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
    };
  }

  /// Başarılı response kontrolü
  bool get isSuccess => response.code >= 200 && response.code < 300;

  /// Hata response kontrolü
  bool get isError => !isSuccess;
}

class ResponseInfo {
  ResponseInfo({
    required this.code,
    this.message,
  });

  factory ResponseInfo.fromJson(Map<String, dynamic> json) {
    return ResponseInfo(
      code: json['code'] as int,
      message: json['message'] as String?,
    );
  }

  final int code;
  final String? message;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
    };
  }
}

// Hata durumları için özel model
class ErrorResponse {
  ErrorResponse({
    required this.success,
    required this.data,
    required this.message,
    required this.errorCode,
    required this.path,
  });

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'],
      message: json['message'] as String? ?? '',
      errorCode: json['errorCode'] as String? ?? '',
      path: json['path'] as String? ?? '',
    );
  }

  final bool success;
  final dynamic data; // null olabilir
  final String message;
  final String errorCode;
  final String path;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'errorCode': errorCode,
      'path': path,
    };
  }

  /// Hata mesajını döndürür (backward compatibility için)
  String get errorMessage => message.isNotEmpty ? message : 'Bilinmeyen hata';

  /// Başarılı response kontrolü (backward compatibility için)
  bool get isSuccess => success;
}
