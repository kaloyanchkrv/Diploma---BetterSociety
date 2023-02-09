// ignore_for_file: prefer_const_constructors

import 'package:bettersociety/pages/location.controller.dart';
import 'package:bettersociety/widgets/main-header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'location_search_dialogue.dart';

class CreatePostPage extends StatefulWidget {
  @override
  CreatePostPageState createState() => CreatePostPageState();
}

class CreatePostPageState extends State<CreatePostPage> {
  late GoogleMapController _mapController;
  late Position position;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController = TextEditingController();
  late TextEditingController _addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(LocationController());
    WidgetsFlutterBinding.ensureInitialized();
    return GetBuilder<LocationController>(builder: (locationController) {
      return Scaffold(
          appBar: Header(removeBackButton: false, titleText: 'Create Post'),
          body: ListView(children: <Widget>[
            Container(
                height: 220,
                width: MediaQuery.of(context).size.width,
                child: Center(
                    child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    child: GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                          target: LatLng(42.6677106, 23.302082), zoom: 10.0),
                    ),
                  ),
                ))),
            Container(
                padding: EdgeInsets.only(top: 35, left: 20, right: 30),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          validator: (value) =>
                              value!.isEmpty ? 'Field is mandatory' : null,
                          controller: _descriptionController,
                          decoration: InputDecoration(
                              labelText: 'Description',
                              labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              )),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          validator: (value) =>
                              value!.isEmpty ? 'Field is mandatory' : null,
                          controller: _addressController,
                          decoration: InputDecoration(
                              labelText: 'Address',
                              labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              )),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                            height: 40,
                            child: Material(
                                borderRadius: BorderRadius.circular(20),
                                shadowColor: Colors.greenAccent,
                                color: Colors.greenAccent,
                                elevation: 7,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      Navigator.pushNamed(context, "/home");
                                    }
                                  },
                                  child: const Center(
                                    child: Text(
                                      "Upload",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ))),
                        SizedBox(
                          height: 15,
                        ),
                      ],
                    ))),
          ]));
    });
  }
}
