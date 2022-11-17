import 'dart:convert';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'package:clima/screens/city_screen.dart';
import 'package:flutter/material.dart';
import 'package:clima/utilities/constants.dart';
import 'package:clima/services/weather.dart';
import 'package:intl/intl.dart';
import 'package:clima/services/aqi.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class LocationScreen extends StatefulWidget {
  LocationScreen({this.locationWeather, this.aqIndex, this.forecast});
  final locationWeather;
  final aqIndex;
  var forecast;
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
      print('City: $cityName');
    });
  }

  Future<int> findStartTimeIndex(
      dynamic forecastTimeList, dynamic i, DateTime current) async {
    var dataTime = DateTime.parse(forecastTimeList[i]['dt_txt']);
    print('from findStartTimeIndex now: $current\tdata: $dataTime');
    if (current.compareTo(dataTime) > 0) {
      return findStartTimeIndex(forecastTimeList, i + 1, current);
    }
    return i;
  }

  Future<int> getStartTimeIndex(dynamic forecastData, dynamic area) async {
    tz.initializeTimeZones();
    var detroit = tz.getLocation(area);
    var extract = tz.TZDateTime.now(detroit);
    var now = DateTime.parse(DateFormat('yyyy-MM-dd hh:00:00').format(extract));
    print('from getStartTimeIndex: $now');
    //int len = forecastData['list'].length;
    int startIndex = await findStartTimeIndex(forecastData['list'], 0, now);
    return startIndex;
  }

  void updateForecast(dynamic forecastData, dynamic start) {
    setState(() {
      widget.forecast = [];
      for (int i = start; i < start + 8; i++) {
        var temp = [];
        temp.add(forecastData['list'][i]['main']['temp']);
        temp.add(forecastData['list'][0]['weather'][0]['icon']);
        temp.add(DateTime.parse(forecastData['list'][i]['dt_txt']));
        widget.forecast.add(temp);
      }
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
          condition = "Sensitive";
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
                  TextButton(
                    onPressed: () async {
                      var weatherData = await weatherModel.getLocationWeather();
                      var aqiData = await aqiModel.getLocationAQI(cityName);
                      dynamic longitude = weatherData['coord']['lon'];
                      dynamic latitude = weatherData['coord']['lat'];
                      var forecastData = await weatherModel.getCityForecast(
                          latitude, longitude);
                      dynamic area =
                          tzmap.latLngToTimezoneString(latitude, longitude);
                      print('area: $area');
                      int start = await getStartTimeIndex(forecastData, area);
                      print('startIndex: $start');
                      updateUI(weatherData);
                      updateAQI(aqiData);
                      updateForecast(forecastData, start);
                    },
                    child: Icon(
                      Icons.near_me,
                      color: Colors.white70,
                      size: 30,
                    ),
                  ),
                  TextButton(
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
                        var aqiData = await aqiModel.getLocationAQI(typedName);
                        dynamic longitude = weatherData['coord']['lon'];
                        dynamic latitude = weatherData['coord']['lat'];
                        var forecastData = await weatherModel.getCityForecast(
                            latitude, longitude);
                        print(
                            'From forecast: lat: $latitude \tlon: $longitude');
                        dynamic area =
                            tzmap.latLngToTimezoneString(latitude, longitude);
                        print('area: $area');
                        int start = await getStartTimeIndex(forecastData, area);
                        print('startIndex: $start');
                        updateUI(weatherData);
                        updateAQI(aqiData);
                        updateForecast(forecastData, start);
                      }
                    },
                    child: Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 30,
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
                      style: kTempTextStyle,
                    ),
                    Text(
                      weatherIcon,
                      style: kConditionTextStyle,
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 10.0),
                height: 80,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: widget.forecast.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Container(
                          width: 55,
                          height: 80,
                          decoration: new BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFFffffff).withOpacity(0.2),
                                  Color(0xFFFFFFFF).withOpacity(0.5),
                                ],
                                stops: [
                                  0.1,
                                  1,
                                ]),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                  DateFormat('h a')
                                      .format(widget.forecast[index][2]),
                                  style: kForecastStyle),
                              Image(
                                width: 40,
                                height: 40,
                                image: NetworkImage(
                                  'https://openweathermap.org/img/w/${widget.forecast[index][1]}.png',
                                ),
                              ),
                              Text(
                                  widget.forecast[index][0].toInt().toString() +
                                      '°C',
                                  style: kForecastStyle)
                            ],
                          ),
                        ),
                      );
                    }),
              ),
              Align(
                child: GlassmorphicContainer(
                  width: 350,
                  height: 350,
                  borderRadius: 20,
                  blur: 2,
                  alignment: Alignment.bottomCenter,
                  border: 2,
                  linearGradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFffffff).withOpacity(0.1),
                        Color(0xFFFFFFFF).withOpacity(0.05),
                      ],
                      stops: [
                        0.1,
                        1,
                      ]),
                  borderGradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFffffff).withOpacity(0.5),
                      Color((0xFFFFFFFF)).withOpacity(0.5),
                    ],
                  ),
                  child: Container(
                    width: 350,
                    height: 350,
                    child: Column(
                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                'Low: $min°C\t\t High: $max°C',
                                style: area > 304000
                                    ? kSubDetailTextStyleLarge
                                    : kSubDetailTextStyle,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                'Humidity: $humidity%\t\t Cloud: $cloud%',
                                style: area > 304000
                                    ? kSubDetailTextStyleLarge
                                    : kSubDetailTextStyle,
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Text(
                                'UV: 4\t\t Wind: 2m/s',
                                style: area > 304000
                                    ? kSubDetailTextStyleLarge
                                    : kSubDetailTextStyle,
                              )),
                          SizedBox(
                            height: 20,
                          ),
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
                                    fontSize: area > 304000 ? 20 : 18,
                                    color: Colors.white,
                                    fontFamily: 'Spartan MB',
                                  ),
                                ),
                              ])),
                          SizedBox(
                            height: 20,
                          ),
                          Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TyperAnimatedText(
                                      'Feels like $feel°C with $description.',
                                      textStyle: area > 304000
                                          ? kDetailTextStyleLarge
                                          : kDetailTextStyle,
                                      speed: const Duration(milliseconds: 200)),
                                  TyperAnimatedText(
                                      '$weatherMessage in $cityName.',
                                      textStyle: area > 304000
                                          ? kDetailTextStyleLarge
                                          : kDetailTextStyle,
                                      speed: const Duration(milliseconds: 200))
                                ],
                                totalRepeatCount: 10,
                                pause: const Duration(seconds: 4),
                                displayFullTextOnTap: true,
                                stopPauseOnTap: true,
                              )),
                        ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
