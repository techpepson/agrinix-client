import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer' as dev;

class WeatherServices {
  final Dio _dio = Dio();
  final String _apiKey = "0e6b4ee78e214404b2b23400250707";
  final String _baseUrl = "https://api.weatherapi.com/v1/current.json";

  Future<Map<String, dynamic>> fetchWeatherConditions(Position position) async {
    try {
      dev.log('API Key: $_apiKey');
      // Build the URL with lat,long format
      final url =
          '$_baseUrl?key=$_apiKey&q=${position.latitude},${position.longitude}';
      dev.log('Calling weather API: $url');

      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        dev.log('Weather data fetched successfully');
        dev.log('Current temp: ${data['current']['temp_c']}°C');
        dev.log('Weather description: ${data['current']['condition']['text']}');

        return _formatWeatherData(data);
      } else {
        throw Exception('Failed to fetch weather data: ${response.statusCode}');
      }
    } catch (e) {
      dev.log('Error fetching weather: $e');
      throw Exception('Failed to fetch weather data: $e');
    }
  }

  Map<String, dynamic> _formatWeatherData(Map<String, dynamic> data) {
    final current = data['current'];
    final condition = current['condition'];
    final location = data['location'];

    return {
      'temperature': current['temp_c'].round(),
      'feels_like': current['feelslike_c'].round(),
      'humidity': current['humidity'],
      'wind_speed': current['wind_kph'] / 3.6, // Convert km/h to m/s
      'uv_index': current['uv'],
      'description': condition['text'],
      'icon': condition['icon'],
      'pressure': current['pressure_mb'],
      'visibility': current['vis_km'],
      'sunrise':
          location['sunrise'] != null ? _parseTime(location['sunrise']) : null,
      'sunset':
          location['sunset'] != null ? _parseTime(location['sunset']) : null,
      'timestamp': DateTime.fromMillisecondsSinceEpoch(
        current['last_updated_epoch'] * 1000,
      ),
    };
  }

  DateTime? _parseTime(String timeString) {
    try {
      // Parse time string like "06:30 AM"
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPM = parts[1] == 'PM';

      final adjustedHour =
          isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);

      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day, adjustedHour, minute);
    } catch (e) {
      dev.log('Error parsing time: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getWeatherForLocation(Position position) async {
    try {
      final weatherData = await fetchWeatherConditions(position);

      // Get current date info
      final now = DateTime.now();
      final currentDay = _getDayName(now.weekday);
      final currentMonth = _getMonthName(now.month);
      final currentYear = now.year;

      return {
        'currentDay': currentDay,
        'currentMonth': currentMonth,
        'currentYear': currentYear,
        'description': weatherData['description'],
        'temperature': weatherData['temperature'],
        'weatherData': [
          {'name': 'Humidity', 'value': weatherData['humidity'], 'unit': '%'},
          {
            'name': 'Wind Speed',
            'value': weatherData['wind_speed'].toStringAsFixed(1),
            'unit': 'm/s',
          },
          {
            'name': 'UV Index',
            'value': weatherData['uv_index'].toStringAsFixed(1),
            'unit': '',
          },
          {'name': 'Pressure', 'value': weatherData['pressure'], 'unit': 'hPa'},
        ],
      };
    } catch (e) {
      dev.log('Error in getWeatherForLocation: $e');
      // Return default data if weather fetch fails
      return {
        'currentDay': 'Monday',
        'currentMonth': 'January',
        'currentYear': 2024,
        'description': 'sunny',
        'temperature': 25,
        'weatherData': [
          {'name': 'Humidity', 'value': 65, 'unit': '%'},
          {'name': 'Wind Speed', 'value': 5.2, 'unit': 'm/s'},
          {'name': 'UV Index', 'value': '7.5', 'unit': ''},
          {'name': 'Pressure', 'value': 1013, 'unit': 'hPa'},
        ],
      };
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Unknown';
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return 'Unknown';
    }
  }
}
