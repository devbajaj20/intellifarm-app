import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {

  static const Map<String, String> headers = {
    "Content-Type": "application/json"
  };

  // --------------------------------------------------
  // Fetch metadata
  // --------------------------------------------------
  static Future<Map<String, dynamic>> fetchMetadata() async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/metadata");

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load metadata: ${response.body}");
      }
    } catch (e) {
      throw Exception("Metadata error: $e");
    }
  }

  // --------------------------------------------------
  // Explain crop (AI explanation)
  // --------------------------------------------------
  static Future<String> explainCrop({
    required String crop,
    required String soil,
    required String n,
    required String p,
    required String k,
    required String ph,
    required String temperature,
    required String humidity,
    required String rainfall,
    required double confidence,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}/explain-crop"),
        headers: headers,
        body: jsonEncode({
          "crop": crop,
          "soil": soil,
          "N": n,
          "P": p,
          "K": k,
          "ph": ph,
          "temperature": temperature,
          "humidity": humidity,
          "rainfall": rainfall,
          "confidence": confidence,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["explanation"] ?? "No explanation available";
      } else {
        throw Exception("Explanation failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Explain crop error: $e");
    }
  }

  // --------------------------------------------------
  // Recommend crop
  // --------------------------------------------------
  static Future<Map<String, dynamic>> recommendCrop(
      Map<String, dynamic> payload) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/recommend-crop");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Crop recommendation failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Crop API error: $e");
    }
  }

  // --------------------------------------------------
  // Recommend fertilizer
  // --------------------------------------------------
  static Future<Map<String, dynamic>> recommendFertilizer(
      Map<String, dynamic> payload) async {
    try {
      final url = Uri.parse("${ApiConfig.baseUrl}/recommend-fertilizer");

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Fertilizer recommendation failed: ${response.body}");
      }
    } catch (e) {
      throw Exception("Fertilizer API error: $e");
    }
  }
}