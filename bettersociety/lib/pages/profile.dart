import 'dart:io';

import 'package:bettersociety/models/user.dart';
import 'package:bettersociety/pages/post.dart';
import 'package:bettersociety/widgets/progress-bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../main.dart';
import '../widgets/main-header.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;
  ProfilePage({required this.profileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;
  final String? currentUserId = currentUser?.id;
  final postsRef = FirebaseFirestore.instance.collection('posts');
  late String imageUrl = "";
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await postsRef.where('ownerId', isEqualTo: widget.profileId).get();

    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  void SelectedItem(BuildContext context, item) {
    switch (item) {
      case 1:
        Navigator.pushNamed(context, '/achievements');
        break;
      case 2:
        print("User Logged out");
        auth.signOut();
        Navigator.pushNamed(context, '/login');
        break;
    }
  }

  edit() {
    Navigator.pushNamed(context, '/edit-profile');
  }

  buildButton({required String text, required Function func}) {
    return Container(
        padding: EdgeInsets.only(top: 2.0),
        child: TextButton(
          onPressed: () => func(),
          child: Container(
            width: 250.0,
            height: 25.0,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.greenAccent),
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }

  editProfile() {
    bool isMe = currentUserId == widget.profileId;
    if (isMe) {
      return buildButton(
        text: "Edit Profile",
        func: () => edit(),
      );
    }
  }

  buildCount(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    }
    return Column(
        children: List.generate(
      posts.length,
      (index) => Column(
        children: [
          posts[index],
          Divider(),
        ],
      ),
    ));
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.doc(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        UserModel user =
            UserModel.fromDocument(snapshot.data as DocumentSnapshot<Object?>);
        return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                        child: auth.currentUser!.photoURL == ""
                            ? const CircleAvatar(
                                child: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 80,
                                ),
                              )
                            : CircleAvatar(
                                radius: 40.0,
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(auth.currentUser!.photoURL!),
                              )),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              buildCount("posts", postCount),
                              buildCount("followers", 0),
                              buildCount("following", 0),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              editProfile(),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.bio,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
              ],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
                textTheme: TextTheme().apply(bodyColor: Colors.black),
                dividerColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.white)),
            child: PopupMenuButton<int>(
              color: Colors.white,
              itemBuilder: (context) => [
                PopupMenuItem<int>(value: 0, child: Text("Achievements")),
                PopupMenuDivider(),
                PopupMenuItem<int>(
                    value: 2,
                    child: Row(
                      children: const [
                        Icon(
                          Icons.logout,
                          color: Colors.red,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text("Logout")
                      ],
                    )),
              ],
              onSelected: (item) => SelectedItem(context, item),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        title: Text(
          "Profile",
          style: GoogleFonts.signika(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: ListView(children: <Widget>[
        buildProfileHeader(),
        Divider(
          height: 0.0,
        ),
        buildProfilePosts(),
      ]),
    );
  }
}
