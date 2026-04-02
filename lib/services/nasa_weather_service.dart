import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nasa_weather.dart';

class NasaWeatherService {
  static Future<NasaWeather?> fetchWeather({
    required double lat,
    required double lon,
  }) async {
    final today = DateTime.now();
    final date =
        "${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}";

    final url =
        "https://power.larc.nasa.gov/api/temporal/daily/point"
        "?parameters=T2M,RH2M,PRECTOTCORR"
        "&community=AG"
        "&longitude=$lon"
        "&latitude=$lat"
        "&start=$date"
        "&end=$date"
        "&format=JSON";

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body);

    final temp =
        data['properties']['parameter']['T2M'][date]?.toDouble() ?? 0.0;
    final humidity =
        data['properties']['parameter']['RH2M'][date]?.toDouble() ?? 0.0;
    final rain =
        data['properties']['parameter']['PRECTOTCORR'][date]?.toDouble() ?? 0.0;

    final condition = rain > 2
        ? "Rainy"
        : humidity > 75
        ? "Cloudy"
        : "Sunny";

    return NasaWeather(
      temperature: temp,
      humidity: humidity,
      rainfall: rain,
      condition: condition,
    );
  }
}
