import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/live_weather.dart';

class LiveWeatherService {
  static const String _apiKey = "b2cf7ced19646e4c825197e97e20bef7";

  /// 🌦 WEATHER BY LAT / LON
  static Future<LiveWeather?> fetch(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather"
        "?lat=$lat&lon=$lon&units=metric&appid=$_apiKey";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return null;

    return LiveWeather.fromJson(jsonDecode(res.body));
  }

  /// 🔍 WEATHER BY CITY NAME (MANUAL SEARCH)
  static Future<LiveWeather?> fetchByCity(String city) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather"
        "?q=$city&units=metric&appid=$_apiKey";

    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return null;

    return LiveWeather.fromJson(jsonDecode(res.body));
  }
}
