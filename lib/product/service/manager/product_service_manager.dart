// ignore_for_file: only_throw_errors

import 'dart:io';

import 'package:Ok/product/cache/simple_cache_manager.dart';
import 'package:Ok/product/init/config/app_environment.dart';
import 'package:Ok/product/utility/platform/platform_os_id.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gen/gen.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibration/vibration.dart';

class ApiService {
  ApiService() {
    // Her request'ten önce token'ı kontrol edip header'a ekleyen interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Hive'dan token'ı al
          final token = _hiveBox.get(CacheKeys.authToken);
          if (token != null && token.isNotEmpty) {
            // Token varsa Authorization header'ına ekle
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppEnvironmentItems.baseUrl.value,
      headers: {'client-id': 1, 'os-id': resolvePlatformOsId()},
    ),
  );

  final Box<String> _hiveBox = Hive.box<String>(HiveBoxNames.auth);

  void setTimeout(Duration duration) {
    _dio.options.connectTimeout = duration;
    _dio.options.receiveTimeout = duration;
    _dio.options.sendTimeout = duration;
  }

  void setBearerToken(String token) {
    // Token'ı hem Dio header'ına hem de Hive'a kaydet
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _hiveBox.put(CacheKeys.authToken, token);
  }

  void setContentType(String type) {
    _dio.options.headers['Content-Type'] = type;
  }

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  Future<T> getRequest<T>(
    String path, {
    T Function(Map<String, dynamic>)? fromJsonMap,
    T Function(List<dynamic>)? fromJsonList,
    Map<String, dynamic>? queryParams,
    RxString? errorMessage,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data?['success'] == true) {
          if (data?['logout'] == 1) {
            //TODO: login sayfasına yönlendir
          }
          if (data?['data'] is Map<String, dynamic> && fromJsonMap != null) {
            //* bu durumda map'e parse et
            final clearData = data?['data'] as Map<String, dynamic>;
            return fromJsonMap(clearData);
          } else if (data?['data'] is List<dynamic> && fromJsonList != null) {
            //* bu durumda list'e parse et
            final clearData = data?['data'] as List<dynamic>;
            return fromJsonList(clearData);
          } else {
            throw Exception('No parser provided for the response type');
          }
        } else {
          //* Error model'e parse et
          final errorResponse = ErrorResponse.fromJson(
            data!,
          );
          debugPrint('********************************');
          debugPrint('path: $path');
          debugPrint("success: ${errorResponse.isSuccess}");
          debugPrint("message: ${errorResponse.errorMessage}");
          debugPrint("errorCode: ${errorResponse.errorCode}");
          debugPrint("path: ${errorResponse.path}");
          debugPrint('********************************');
          // Haptic feedback ver
          await _triggerHapticFeedback(path: path);
          throw errorResponse;
        }
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          error: 'API returned status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return _handleError(e, errorMessage, path);
    }
  }

  Future<T> postRequest<T>(
    String path, {
    T Function(Map<String, dynamic>)? fromJsonMap,
    T Function(List<dynamic>)? fromJsonList,
    FormData? formData,
    Map<String, dynamic>? data,
    RxString? errorMessage,
  }) async {
    try {
      final fullUrl = '${_dio.options.baseUrl}$path';
      final headers = _dio.options.headers;
      if (kDebugMode) {
        print('İstek atılan URL: $fullUrl');
        print('İstek atılan headers: $headers');
        if (formData != null) {
          print('FormData içeriği:');
          printFormData(formData);
        }
      }

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData ?? data,
      );

      if (kDebugMode) {
        print('Ham Response:');
        print('Status Code: ${response.statusCode}');
        print('Headers: ${response.headers}');
        print('Data: ${response.data}');
        print('response: $response');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (kDebugMode) {
          print(responseData);
        }

        if (responseData?['success'] == true) {
          if (responseData?['logout'] == 1) {
            //Todo: login sayfasına yönlendir
            //await Get.offAllNamed(AppRoutes.login.value);
          }

          // Boş obje durumu için kontrol (createPassword gibi)
          if (responseData?['data'] is Map<String, dynamic> &&
              (responseData?['data'] as Map<String, dynamic>).isEmpty) {
            if (errorMessage != null) {
              errorMessage.value = '';
            }
            return null as T; // Boş response için null döndür
          }

          if (responseData?['data'] is Map<String, dynamic> &&
              fromJsonMap != null) {
            //* bu durumda map'e parse et
            final clearData = responseData?['data'] as Map<String, dynamic>;
            if (errorMessage != null) {
              errorMessage.value = '';
            }
            return fromJsonMap(clearData);
          } else if (responseData?['data'] is List<dynamic> &&
              fromJsonList != null) {
            //* bu durumda list'e parse et
            final clearData = responseData?['data'] as List<dynamic>;
            if (errorMessage != null) {
              errorMessage.value = '';
            }
            return fromJsonList(clearData);
          } else {
            throw Exception('No parser provided for the response type');
          }
        } else {
          if (kDebugMode) {
            print('responseData: $responseData');
          }
          //* Error model'e parse et
          final errorResponse = ErrorResponse.fromJson(
            responseData!,
          );
          debugPrint('********************************');
          debugPrint('path: $path');
          debugPrint("success: ${errorResponse.isSuccess}");
          debugPrint("message: ${errorResponse.errorMessage}");
          debugPrint("errorCode: ${errorResponse.errorCode}");
          debugPrint("path: ${errorResponse.path}");
          debugPrint('********************************');
          throw errorResponse;
        }
      } else {
        if (kDebugMode) {
          print('response: $response');
        }
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          error:
              'API returned status code ${response.statusCode} ${response.data}',
        );
      }
    } on DioException catch (e) {
      return _handleError(e, errorMessage, path);
    }
  }

  T _handleError<T>(DioException error, RxString? errorMessage, String path) {
    // Haptic feedback ver
    _triggerHapticFeedback(path: path);

    if (error.response != null && error.response?.data != null) {
      final data = error.response!.data;
      if (kDebugMode) {
        print('************** Error Response (Ham) ******************');
        print('path: $path');
        print('Status Code: ${error.response?.statusCode}');
        print('Headers: ${error.response?.headers}');
        print('Data: $data');
        print('************** Error Response (Ham) ******************');
      }
      if (data is Map<String, dynamic>) {
        final errorResponse = ErrorResponse.fromJson(data);
        if (errorMessage != null) {
          errorMessage.value = errorResponse.errorMessage;
        }
        // Logout kontrolü yeni formatta yok

        debugPrint('************** Error Response ******************');
        debugPrint('path: $path');
        //printFormData(formData!); // FormData içeriğini yazdırır
        debugPrint('success: ${errorResponse.isSuccess}');
        debugPrint('message: ${errorResponse.errorMessage}');
        debugPrint('errorCode: ${errorResponse.errorCode}');
        debugPrint('data: ${errorResponse.data}');
        debugPrint('************** Error Response ******************');
        throw errorResponse;
      } else {
        debugPrint('Bilinmeyen error response formatı: $data');
        throw Exception('Bilinmeyen error response formatı');
      }
    } else {
      debugPrint('Network error occurred: ${error.message}');
      debugPrint('Error type: ${error.type}');
      debugPrint('Error response: ${error.response}');
      debugPrint('Error request options: ${error.requestOptions}');
      throw Exception('Network error occurred: ${error.message}');
    }
  }

  /// Haptic feedback verilmeyecek path'lerin listesi
  final List<String> _excludedPathsFromHaptic = [
    // Buraya haptic feedback verilmeyecek path'leri ekleyin
  ];

  /// Haptic feedback tetikler (error durumlarında)
  /// [path] parametresi verilirse, o path haptic feedback listesinde değilse feedback verir
  Future<void> _triggerHapticFeedback({String? path}) async {
    if (path != null && _excludedPathsFromHaptic.contains(path)) {
      return;
    }

    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 300);
      }
    } catch (e) {
      // Haptic feedback hatası sessizce yok sayılır
      debugPrint('Haptic feedback error: $e');
    }
  }

  void printFormData(FormData formData) {
    for (final field in formData.fields) {
      debugPrint('Field: ${field.key}: ${field.value}');
    }

    for (final file in formData.files) {
      debugPrint('File: ${file.key}: ${file.value.filename}');
    }
  }

  Future<T> putRequest<T>(
    String path, {
    T Function(Map<String, dynamic>)? fromJsonMap,
    T Function(List<dynamic>)? fromJsonList,
    FormData? formData,
    Map<String, dynamic>? data,
    RxString? errorMessage,
  }) async {
    try {
      final fullUrl = '${_dio.options.baseUrl}$path';
      final headers = _dio.options.headers;
      if (kDebugMode) {
        print('PUT İstek atılan URL: $fullUrl');
        print('PUT İstek atılan headers: $headers');
        if (formData != null) {
          print('PUT FormData içeriği:');
          printFormData(formData);
        }
      }

      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: formData ?? data,
      );

      if (kDebugMode) {
        print('PUT Ham Response:');
        print('Status Code: ${response.statusCode}');
        print('Headers: ${response.headers}');
        print('Data: ${response.data}');
        print('response: $response');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (kDebugMode) {
          print(responseData);
        }

        // Response direkt data objesi olarak geliyorsa (success wrapper yoksa)
        if (responseData is Map<String, dynamic>) {
          // Eğer success field'ı varsa, standart format
          if (responseData.containsKey('success')) {
            if (responseData['success'] == true) {
              if (responseData['logout'] == 1) {
                //Todo: login sayfasına yönlendir
                //await Get.offAllNamed(AppRoutes.login.value);
              }

              // Boş obje durumu için kontrol (createPassword gibi)
              if (responseData['data'] is Map<String, dynamic> &&
                  (responseData['data'] as Map<String, dynamic>).isEmpty) {
                if (errorMessage != null) {
                  errorMessage.value = '';
                }
                return responseData['data']
                    as T; // Boş response için null döndür
              }

              if (responseData['data'] is Map<String, dynamic> &&
                  fromJsonMap != null) {
                //* bu durumda map'e parse et
                final clearData = responseData['data'] as Map<String, dynamic>;
                if (errorMessage != null) {
                  errorMessage.value = '';
                }
                return fromJsonMap(clearData);
              } else if (responseData['data'] is List<dynamic> &&
                  fromJsonList != null) {
                //* bu durumda list'e parse et
                final clearData = responseData['data'] as List<dynamic>;
                if (errorMessage != null) {
                  errorMessage.value = '';
                }
                return fromJsonList(clearData);
              } else {
                throw Exception('No parser provided for the response type');
              }
            } else {
              // Error durumu
              if (kDebugMode) {
                print('responseData: $responseData');
              }
              final errorResponse = ErrorResponse.fromJson(
                responseData,
              );
              debugPrint('********************************');
              debugPrint('path: $path');
              debugPrint("success: ${errorResponse.isSuccess}");
              debugPrint("message: ${errorResponse.errorMessage}");
              debugPrint("errorCode: ${errorResponse.errorCode}");
              debugPrint("path: ${errorResponse.path}");
              debugPrint('********************************');
              await _triggerHapticFeedback(path: path);
              throw errorResponse;
            }
          } else {
            // Success wrapper yok, direkt data objesi
            if (fromJsonMap != null) {
              if (errorMessage != null) {
                errorMessage.value = '';
              }
              return fromJsonMap(responseData);
            } else {
              throw Exception('No parser provided for the response type');
            }
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        if (kDebugMode) {
          print('response: $response');
        }
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          error:
              'API returned status code ${response.statusCode} ${response.data}',
        );
      }
    } on DioException catch (e) {
      return _handleError(e, errorMessage, path);
    }
  }

  //* Özel durumlar için - data alanı null olan response'lar için
  Future<Map<String, dynamic>> postRequestWithFullResponse(
    String path, {
    Map<String, dynamic>? data,
    FormData? formData,
    RxString? errorMessage,
  }) async {
    try {
      final fullUrl = '${_dio.options.baseUrl}$path';
      final headers = _dio.options.headers;
      if (kDebugMode) {
        print('İstek atılan URL: $fullUrl');
        print('İstek atılan headers: $headers');
        if (formData != null) {
          print('FormData içeriği:');
          printFormData(formData);
        }
      }

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData ?? data,
      );

      if (kDebugMode) {
        print('Ham Response:');
        print('Status Code: ${response.statusCode}');
        print('Headers: ${response.headers}');
        print('Data: ${response.data}');
        print('response: $response');
      }

      if (response.statusCode == 200) {
        final responseData = response.data!;

        if (kDebugMode) {
          print(responseData);
        }

        if (responseData['success'] == true) {
          if (responseData['logout'] == 1) {
            //Todo: login sayfasına yönlendir
            //await Get.offAllNamed(AppRoutes.login.value);
          }

          if (errorMessage != null) {
            errorMessage.value = '';
          }

          // Tüm response'u döndür (data null olsa bile)
          return responseData;
        } else {
          if (kDebugMode) {
            print('responseData: $responseData');
          }
          //* Error model'e parse et
          final errorResponse = ErrorResponse.fromJson(responseData);
          if (errorMessage != null) {
            errorMessage.value = errorResponse.errorMessage;
          }
          // Haptic feedback ver
          await _triggerHapticFeedback(path: path);
          throw errorResponse;
        }
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          error: 'API returned status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      return _handleError(e, errorMessage, path);
    }
  }

  Future<T> deleteRequest<T>(
    String path, {
    T Function(Map<String, dynamic>)? fromJsonMap,
    T Function(List<dynamic>)? fromJsonList,
    FormData? formData,
    Map<String, dynamic>? data,
    RxString? errorMessage,
  }) async {
    try {
      final fullUrl = '${_dio.options.baseUrl}$path';
      final headers = _dio.options.headers;
      if (kDebugMode) {
        print('DELETE İstek atılan URL: $fullUrl');
        print('DELETE İstek atılan headers: $headers');
        if (formData != null) {
          print('DELETE FormData içeriği:');
          printFormData(formData);
        }
        if (data != null) {
          print('DELETE Data içeriği: $data');
        }
      }

      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: formData ?? data,
      );

      if (kDebugMode) {
        print('DELETE Ham Response:');
        print('Status Code: ${response.statusCode}');
        print('Headers: ${response.headers}');
        print('Data: ${response.data}');
        print('response: $response');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (kDebugMode) {
          print(responseData);
        }

        // Response direkt data objesi olarak geliyorsa (success wrapper yoksa)
        if (responseData is Map<String, dynamic>) {
          // Eğer success field'ı varsa, standart format
          if (responseData.containsKey('success')) {
            if (responseData['success'] == true) {
              if (responseData['logout'] == 1) {
                //Todo: login sayfasına yönlendir
                //await Get.offAllNamed(AppRoutes.login.value);
              }

              if (responseData['data'] is Map<String, dynamic> &&
                  fromJsonMap != null) {
                final clearData = responseData['data'] as Map<String, dynamic>;
                if (errorMessage != null) {
                  errorMessage.value = '';
                }
                return fromJsonMap(clearData);
              } else if (responseData['data'] is List<dynamic> &&
                  fromJsonList != null) {
                final clearData = responseData['data'] as List<dynamic>;
                if (errorMessage != null) {
                  errorMessage.value = '';
                }
                return fromJsonList(clearData);
              } else {
                throw Exception('No parser provided for the response type');
              }
            } else {
              // Error durumu
              final errorResponse = ErrorResponse.fromJson(responseData);
              debugPrint('********************************');
              debugPrint('path: $path');
              debugPrint("success: ${errorResponse.isSuccess}");
              debugPrint("message: ${errorResponse.errorMessage}");
              debugPrint("errorCode: ${errorResponse.errorCode}");
              debugPrint("path: ${errorResponse.path}");
              debugPrint('********************************');
              await _triggerHapticFeedback(path: path);
              throw errorResponse;
            }
          } else {
            // Success wrapper yok, direkt data objesi
            if (fromJsonMap != null) {
              if (errorMessage != null) {
                errorMessage.value = '';
              }
              return fromJsonMap(responseData);
            } else {
              throw Exception('No parser provided for the response type');
            }
          }
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw DioException(
          response: response,
          requestOptions: response.requestOptions,
          error:
              'API returned status code ${response.statusCode} ${response.data}',
        );
      }
    } on DioException catch (e) {
      return _handleError(e, errorMessage, path);
    }
  }
}
