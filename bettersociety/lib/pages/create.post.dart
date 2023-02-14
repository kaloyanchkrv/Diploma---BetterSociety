// ignore_for_file: prefer_const_constructors

import 'package:bettersociety/main.dart';
import 'package:bettersociety/pages/location-controller.dart';
import 'package:bettersociety/widgets/main-header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/user.dart';
import 'home.dart';
import 'location-search-dialogue.dart';
import 'package:uuid/uuid.dart';

class CreatePostPage extends StatefulWidget {
  @override
  CreatePostPageState createState() => CreatePostPageState();
}

class CreatePostPageState extends State<CreatePostPage> {
  late Position position;
  final categories = ['Food Preparing', 'Cleaning', 'Other'];
  String? value;
  final _formKey = GlobalKey<FormState>();
  final postsRef = FirebaseFirestore.instance.collection('posts');
  late final TextEditingController _descriptionController =
      TextEditingController();
  late final TextEditingController _addressController = TextEditingController();
  bool isUploading = false;
  String postId = Uuid().v4();
  late final TextEditingController _captionController = TextEditingController();

  DropdownMenuItem<String> buildMenuItem(String category) => DropdownMenuItem(
      value: category,
      child: Text(category, style: const TextStyle(color: Colors.black)));

  void _uploadPost() async {
    postsRef.add({
      'ownerId': FirebaseAuth.instance.currentUser!.uid,
      'username': currentUser!.username,
      "postId": postId,
      "caption": _captionController.text,
      "description": _descriptionController.text,
      "location": _addressController.text,
      "timestamp": DateTime.now(),
      "likes": {},
    });
    _captionController.clear();
    _descriptionController.clear();
    _addressController.clear();
  }

  @override
  Widget build(BuildContext context) {
    Get.put(LocationController());
    WidgetsFlutterBinding.ensureInitialized();
    return GetBuilder<LocationController>(builder: (locationController) {
      return Scaffold(
          appBar: Header(removeBackButton: false, titleText: 'Create Post'),
          
          body: ListView(children: <Widget>[
            isUploading ? LinearProgressIndicator() : const Text(''),
            Container(
                height: 220,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {},
                        myLocationEnabled: true,
                        initialCameraPosition: CameraPosition(
                            target: LatLng(42.6677106, 23.302082), zoom: 10.0),
                      ),
                    ),
                  ),
                )),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(
                    FirebaseAuth.instance.currentUser!.photoURL.toString()),
              ),
              title: Container(
                child: TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: "Write a caption...",
                      hintStyle: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    )),
              ),
            ),
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
                          height: 40,
                        ),
                        Container(
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(20)),
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              value: value,
                              items: categories.map(buildMenuItem).toList(),
                              onChanged: (value) => setState(() {
                                this.value = value;
                              }),
                              isExpanded: true,
                            ))),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                            height: 35,
                            child: Material(
                                borderRadius: BorderRadius.circular(20),
                                shadowColor: Colors.greenAccent,
                                color: Colors.greenAccent,
                                elevation: 6,
                                child: GestureDetector(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      _uploadPost();
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
                      ],
                    ))),
          ]));
    });
  }
}
