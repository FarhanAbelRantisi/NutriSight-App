import 'dart:io';
import 'package:dio/dio.dart';

class ScanRepository {
  final Dio _dio;
  final String baseUrl;

  ScanRepository({
    Dio? dio,
    this.baseUrl = "https://nutrition-api-464605127931.asia-southeast2.run.app",
  }) : _dio = dio ?? Dio();

  Future<Map<String, dynamic>> classifyImage({
    required String categoryCode,
    required File file,
  }) async {
    final url = "$baseUrl/classify-image-graded";

    final formData = FormData.fromMap({
      'category_code': categoryCode,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.uri.pathSegments.last,
      ),
    });

    final response = await _dio.post(
      url,
      data: formData,
      options: Options(
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

    if (response.data is Map<String, dynamic>) {
      return response.data as Map<String, dynamic>;
    }

    return {
      "raw": response.data,
    };
  }
}
