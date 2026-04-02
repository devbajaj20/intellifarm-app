class LiveWeather {
  final double temperature;
  final int humidity;
  final String condition;
  final String city;   // ✅ ADD THIS

  LiveWeather({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.city,
  });

  factory LiveWeather.fromJson(Map<String, dynamic> json) {
    return LiveWeather(
      temperature: json['main']['temp'].toDouble(),
      humidity: json['main']['humidity'],
      condition: json['weather'][0]['main'],
      city: json['name'], // ✅ CITY FROM OPENWEATHER
    );
  }
}
