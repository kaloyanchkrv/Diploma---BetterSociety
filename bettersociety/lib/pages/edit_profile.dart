import 'dart:async';
import 'dart:io';

import 'package:bettersociety/main.dart';
import 'package:bettersociety/pages/home.dart';
import 'package:bettersociety/widgets/progress_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';

ValueKey key = const ValueKey(0);

class EditProfilePage extends StatefulWidget {
  final String? currentUserId;

  const EditProfilePage({super.key, required this.currentUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _key = GlobalKey<ScaffoldState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  UserModel? user;
  final auth = FirebaseAuth.instance;
  String imageUrl = "";
  bool _bioValid = true;
  bool _usernameValid = true;

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.doc(widget.currentUserId).get();
    user = UserModel.fromDocument(doc);
    usernameController.text = user!.username;
    bioController.text = user!.bio;
    setState(() {
      isLoading = false;
    });
  }

  pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    Reference ref = FirebaseStorage.instance.ref().child(currentUser!.id);

    await ref.putFile(File(image!.path));
    ref.getDownloadURL().then((value) {
      auth.currentUser?.updatePhotoURL(value);

      setState(() {
        imageUrl = value;
      });
    });
  }

  updateProfileData() {
    setState(() {
      usernameController.text.trim().length < 3 ||
              usernameController.text.isEmpty
          ? _usernameValid = false
          : _usernameValid = true;
      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;
      key = ValueKey(key.hashCode + 1);
    });

    if (_usernameValid && _bioValid) {
      usersRef.doc(widget.currentUserId).update({
        "username": usernameController.text,
        "bio": bioController.text,
        "photoUrl": imageUrl,
      });
      const SnackBar snackbar = SnackBar(content: Text("Profile updated!"));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      Timer(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    }
  }

  Column buildUsernameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Username",
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
            controller: usernameController,
            decoration: InputDecoration(
              errorText: _usernameValid ? null : "Username too short",
            )),
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "Bio",
          style: TextStyle(color: Colors.grey),
        ),
        TextField(
            controller: bioController,
            decoration: InputDecoration(
              errorText: _bioValid ? null : "Bio too long",
            )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        appBar: AppBar(
            backgroundColor: Colors.greenAccent,
            centerTitle: true,
            title: const Text('Edit Profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                )),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: isLoading
            ? circularProgress()
            : ListView(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: GestureDetector(
                            onTap: () => pickImage(),
                            child: imageUrl == ""
                                ? const Icon(Icons.person,
                                    size: 50.0, color: Colors.grey)
                                : CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor: Colors.grey,
                                    backgroundImage:
                                        Image.network(imageUrl).image,
                                  )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            buildUsernameField(),
                            const SizedBox(height: 10.0),
                            buildBioField(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton(
                          onPressed: updateProfileData,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.greenAccent),
                          ),
                          child: const Text(
                            "Update Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ));
  }
}
