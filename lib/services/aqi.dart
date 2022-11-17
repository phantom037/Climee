import 'package:clima/services/location.dart';
import 'package:clima/services/networking.dart';

class AQIModel {
  Future<dynamic> getLocationAQI(String cityName) async {
    Location location = Location();
    await location.getCurrentLocation();

    //cityName
    NetWorkHelper networkHelper = NetWorkHelper(
        'https://api.waqi.info/feed/$cityName/?token=1cd658c06d6604648301e071946a552f6010e651');
    var aqiData = await networkHelper.getData();
    return aqiData;
  }
}
