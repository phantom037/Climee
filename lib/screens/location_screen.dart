import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clima/screens/city_screen.dart';
import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'package:intl/intl.dart';
import 'package:clima/services/aqi.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({this.locationWeather, this.aqIndex});
  final locationWeather;
  final aqIndex;
  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  WeatherModel weatherModel = new WeatherModel();
  AQIModel aqiModel = new AQIModel();
  int temperature;
  String weatherIcon;
  String cityName;
  String weatherMessage;
  int min, max, cloud, humidity, feel;
  String description;
  Color aqiColor;
  var aqi, GMT, condition;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateUI(widget.locationWeather);
    updateAQI(widget.aqIndex);
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData == null) {
        temperature = 0;
        weatherIcon = '⚠️';
        weatherMessage = "Unable to get weather data";
        cityName = '';
        min = max = humidity = cloud = feel = 0;
        description = "Unable to get weather data";
        return;
      }
      var temp = weatherData['main']['temp'];
      var minTemp = weatherData['main']['temp_min'];
      var maxTemp = weatherData['main']['temp_max'];
      var feelTemp = weatherData['main']['feels_like'];
      temperature = temp.toInt();
      min = minTemp.toInt();
      max = maxTemp.toInt();
      feel = feelTemp.toInt();

      var condition = weatherData['weather'][0]['id'];
      weatherIcon = weatherModel.getWeatherIcon(condition);
      weatherMessage = weatherModel.getMessage(temperature);
      cityName = weatherData['name'];
      humidity = weatherData['main']['humidity'];
      cloud = weatherData['clouds']['all'];
      description = weatherData['weather'][0]['description'];
    });
  }

  void updateAQI(dynamic aqiData) {
    setState(() {
      if (aqiData == null) {
        aqi = -1;
        return;
      }
      try {
        aqi = aqiData['data']['aqi'];
        GMT = aqiData['data']['time']['s'];
        //print(GMT);
        if (aqi <= 50) {
          aqiColor = Colors.green;
          condition = "Good";
        } else if (aqi <= 100) {
          aqiColor = Colors.yellow;
          condition = "Moderate";
        } else if (aqi <= 150) {
          aqiColor = Colors.orange;
          condition = "Unhealthy for Sensitive Groups";
        } else if (aqi <= 200) {
          aqiColor = Colors.red;
          condition = "Unhealthy";
        } else if (aqi <= 300) {
          aqiColor = Colors.purple;
          condition = "Very Unhealthy";
        } else {
          aqiColor = Color(0xff800000);
          condition = "Hazardous";
        }
      } catch (e) {
        aqi = "Unable to get Data";
        aqiColor = Colors.white;
        condition = "N.A";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var dateTime = GMT == null || GMT == '' ? "N.A" : DateTime.parse(GMT);
    MediaQueryData media = MediaQuery.of(context);
    var width = media.size.width;
    var height = media.size.height;
    double area = width * height;
    print("Area: $area");
    print("GMT: $GMT");
    DateTime now = DateTime.now();
    /*String time = dateTime == "N.A"
        ? "Can not Access Data"
        : DateFormat('kk:mm:ss EEE d MMM').format(dateTime);
     */
    AssetImage background;
    if (dateTime is DateTime) {
      if (dateTime.hour > 1 && dateTime.hour < 11) {
        background = AssetImage('images/sun.jpeg');
      } else if (dateTime.hour < 18) {
        background = AssetImage('images/sky.jpeg');
      } else {
        background = AssetImage('images/star.jpeg');
      }
    } else {
      background = AssetImage('images/cloud.jpeg');
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: background,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.8), BlendMode.dstATop),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  FlatButton(
                    onPressed: () async {
                      var weatherData = await weatherModel.getLocationWeather();
                      updateUI(weatherData);
                      var aqiData = await aqiModel.getLocationAQI(cityName);
                      updateAQI(aqiData);
                    },
                    child: Icon(
                      Icons.near_me,
                      size: area > 304000 ? 50.0 : 40,
                    ),
                  ),
                  FlatButton(
                    onPressed: () async {
                      var typedName = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return CityScreen();
                          },
                        ),
                      );
                      if (typedName != null) {
                        var weatherData =
                            await weatherModel.getCityWeather(typedName);
                        updateUI(weatherData);
                        var aqiData = await aqiModel.getCityAQI(typedName);
                        updateAQI(aqiData);
                      }
                    },
                    child: Icon(
                      Icons.search,
                      size: area > 304000 ? 50.0 : 40,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    Text(
                      '$temperature°C',
                      style:
                          area > 304000 ? kTempTextStyleLarge : kTempTextStyle,
                    ),
                    Text(
                      weatherIcon,
                      style: area > 304000
                          ? kConditionTextStyleLarge
                          : kConditionTextStyle,
                    ),
                  ],
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  child: Text(
                    'Feels like $feel°C with $description.',
                    style: area > 304000
                        ? kDetailTextStyleLarge
                        : kDetailTextStyle,
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Text(
                    'Highest: $max°C\t\t Lowest: $min°C\n\nHumidity: $humidity%\t\t Cloud: $cloud%',
                    style: area > 304000
                        ? kSubDetailTextStyleLarge
                        : kSubDetailTextStyle,
                  )),
              Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Row(children: <Widget>[
                    Text(
                      'AQI: $aqi',
                      style: TextStyle(
                        fontSize: area > 304000 ? 20 : 18,
                        color: aqiColor,
                        fontFamily: 'Spartan MB',
                      ),
                    ),
                    Text(
                      '\t\t$condition',
                      style: TextStyle(
                        fontSize: area > 304000 ? 15 : 12,
                        color: Colors.white,
                        fontFamily: 'Spartan MB',
                      ),
                    ),
                  ])),
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Text(
                  '$weatherMessage in $cityName',
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
