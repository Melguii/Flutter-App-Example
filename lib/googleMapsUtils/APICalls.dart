import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:mapingu_app/googleMapsUtils/locations.dart';


Future<Position> getCoordenades() async {

  bool servei;
  LocationPermission permis;

  servei = await Geolocator.isLocationServiceEnabled();
  if (!servei) {
    return Future.error('No estàn habilitats els serveis.');
  }

  permis = await Geolocator.checkPermission();
  if (permis == LocationPermission.deniedForever) {
    return Future.error(
        "S'ha denegat la localització per sempre");
  }

  if (permis == LocationPermission.denied) {
    permis = await Geolocator.requestPermission();
    if (permis != LocationPermission.whileInUse &&
        permis != LocationPermission.always) {
      return Future.error(
          'Permissos denegats (valor actual: $permis).');
    }
  }



  return await Geolocator.getCurrentPosition();
}

Future<locations> getLocations() async {

  return await getCoordenades().then(
          (value) async {
            print(value);
            final response = await http.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${value.latitude},${value.longitude}&radius=1500&type=point_of_interest&key=AIzaSyAkesGh438L_p1Ox6fhw4DeHWvZbxIHVnc');

            if (response.statusCode == 200) {
              // If the server did return a 200 OK response,
              // then parse the JSON.
              print(response.body);
              var object = locations.fromJson(jsonDecode(response.body));
              return object;
              //return locations.fromJson(jsonDecode(response.body));
            } else {
              // If the server did not return a 200 OK response,
              // then throw an exception.
              print('Failed to load album');
              throw Exception('Failed to load album');
            }
          }
  );
}