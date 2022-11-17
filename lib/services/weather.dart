import 'package:clima/services/location.dart';
import 'package:clima/services/networking.dart';

const apiKey = '39b60e9a2d5c6c2ed36545f8e337031a';
const openWeatherMapURL = 'https://api.openweathermap.org/data/2.5/weather';
const forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

class WeatherModel {
  double longitude;
  double latitude;

  Future<dynamic> getCityWeather(String cityName) async {
    var url = '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric';
    NetWorkHelper netWorkHelper = NetWorkHelper(url);
    var weatherData = await netWorkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getCityDetect() async {
    var url =
        'https://api.openweathermap.org/data/2.5/weather?q=los%20angeles&appid=$apiKey&units=metric';
    NetWorkHelper netWorkHelper = NetWorkHelper(url);
    var weatherData = await netWorkHelper.getData();
    return weatherData;
  }

  Future<dynamic> getCityForecastDetect() async {
    var url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=34.05224&lon=-118.2437&appid=$apiKey&units=metric';
    NetWorkHelper netWorkHelper = NetWorkHelper(url);
    var forecastData = await netWorkHelper.getData();
    return forecastData;
  }

  Future<dynamic> getCityForecast(double lat, double lon) async {
    var url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
    NetWorkHelper netWorkHelper = NetWorkHelper(url);
    var forecastData = await netWorkHelper.getData();
    return forecastData;
  }

  Future<dynamic> getForecast() async {
    Location location = Location();
    await location.getCurrentLocation();

    var forecastLongitude = location.longitude;
    var forecastLatitude = location.latitude;

    NetWorkHelper networkHelper = NetWorkHelper(
        '$forecastUrl?lat=$forecastLatitude&lon=$forecastLongitude&appid=$apiKey&units=metric');
    var forecastData = await networkHelper.getData();
    if (forecastData == null) {
      forecastData = await getCityForecastDetect();
    }
    print('From forecast: lat: $forecastLatitude \tlon: $forecastLongitude');
    return forecastData;
  }

  Future<dynamic> getLocationWeather() async {
    Location location = Location();
    await location.getCurrentLocation();

    longitude = location.longitude;
    latitude = location.latitude;
    NetWorkHelper networkHelper = NetWorkHelper(
        '$openWeatherMapURL?lat=$latitude&lon=$longitude&appid=$apiKey&units=metric');
    var weatherData = await networkHelper.getData();
    if (weatherData == null) {
      weatherData = await getCityDetect();
    }
    print('From weather: lat: $latitude \tlon: $longitude');
    return weatherData;
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}
