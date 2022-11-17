import 'package:clima/services/networking.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'location_screen.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:clima/services/weather.dart';
import 'package:clima/services/aqi.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    getLocationData();
  }

  Future<int> startTimeIndex(
      dynamic forecastTimeList, int i, DateTime current) async {
    var dataTime = DateTime.parse(forecastTimeList[i]['dt_txt']);
    print('now: $current\tdata: $dataTime');
    if (current.compareTo(dataTime) > 0) {
      return startTimeIndex(forecastTimeList, i + 1, current);
    }
    return i;
  }

  void getLocationData() async {
    WeatherModel weatherModel = new WeatherModel();
    var weatherData = await weatherModel.getLocationWeather();
    String city = weatherData['name'];
    AQIModel aqiUS = new AQIModel();
    var aqiData = await aqiUS.getLocationAQI(city);
    dynamic longitude = weatherData['coord']['lon'];
    dynamic latitude = weatherData['coord']['lat'];
    dynamic forecastData =
        await weatherModel.getCityForecast(latitude, longitude);
    var forecastTimeList = [];

    var area = tzmap.latLngToTimezoneString(latitude, longitude);
    //print("real time: $area");

    tz.initializeTimeZones();
    var detroit = tz.getLocation(area);
    var extract = tz.TZDateTime.now(detroit);
    var now = DateTime.parse(DateFormat('yyyy-MM-dd hh:00:00').format(extract));
    //print('real time: $now');
    int len = forecastData['list'].length;
    int startIndex = await startTimeIndex(forecastData['list'], 0, now);
    print('Start: $startIndex');
    for (int i = startIndex; i < startIndex + 8; i++) {
      var temp = [];
      temp.add(forecastData['list'][i]['main']['temp']);
      temp.add(forecastData['list'][i]['weather'][0]['icon']);
      temp.add(DateTime.parse(forecastData['list'][i]['dt_txt']));
      forecastTimeList.add(temp);
    }
    //print(forecastTimeList);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LocationScreen(
        locationWeather: weatherData,
        aqIndex: aqiData,
        forecast: forecastTimeList,
      );
    })); //Navigator
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SpinKitWave(
          color: Colors.white70,
          size: 100,
        ),
      ),
    );
  }
}
