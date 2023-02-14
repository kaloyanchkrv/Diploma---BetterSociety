import 'package:bettersociety/pages/location-controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';

class LocationSearchDialog extends StatelessWidget {
  final GoogleMapController? googleMapController;
  const LocationSearchDialog({super.key, required this.googleMapController});
  

  @override
  Widget build(BuildContext context) {

    final TextEditingController _controller = TextEditingController();

    return Container(
      margin: EdgeInsets.only(top: 150),
      padding: EdgeInsets.all(5),
      alignment: Alignment.topCenter,
      child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: SizedBox(
            width: 250,
            child: TypeAheadField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _controller,
                textInputAction: TextInputAction.search,
                autofocus: true,
                 textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                  hintText: "Search for a location",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(style: BorderStyle.none, width: 0),
                  ),
                  hintStyle: const TextStyle(fontSize: 16),
                  filled: true,
                ),
              ),
              suggestionsCallback: (pattern) async {
                return await Get.find<LocationController>()
                    .searchLocation(context, pattern);
              },
              itemBuilder: (context, Prediction suggestion) {
                return Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        Expanded(
                          child: Text(
                            suggestion.description ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                      ],
                    ));
              },
              onSuggestionSelected: (Prediction suggestion) {
                Get.back();
              },
            ),
          )),
    );
  }
}
