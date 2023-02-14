import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;

import 'location-service.dart';

class LocationController extends GetxController {
  Placemark _pickedLocation = Placemark();
  Placemark get pickedLocation => _pickedLocation;

  List<Prediction> _predictions = [];

  set googleMapController(GoogleMapController googleMapController) {}

  Future<List<Prediction>> searchLocation(
      BuildContext context, String text) async {
    if (text.isNotEmpty) {
      http.Response response = await getLocationData(text);
      var data = jsonDecode(response.body.toString());
      if (data['status'] == 'OK') {
        _predictions = [];
        data['predictions'].forEach(
            (prediction) => _predictions.add(Prediction.fromJson(prediction)));
      } else {

      }
    }
    return _predictions;
  }
}
