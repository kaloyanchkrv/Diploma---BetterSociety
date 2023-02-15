// ignore_for_file: prefer_const_constructors

import 'package:bettersociety/main.dart';
import 'package:bettersociety/models/user.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../widgets/progress-bar.dart';
import 'home.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot>? searchResultsFuture;

  buildSearchResults() {
    return FutureBuilder(
      future: searchResultsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: circularProgress(),
          );
        }
        List<UserResult> searchResults = [];
        snapshot.data!.docs.forEach((doc) {
          UserModel user = UserModel.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        });
        return ListView(
          children: searchResults,
        );
      },
    );
  }

  handleSearch(String query) {
    Future<QuerySnapshot> users =
        usersRef.where("username", isGreaterThanOrEqualTo: query).get();
    setState(() {
      searchResultsFuture = users;

      if (searchResultsFuture == null) {
        circularProgress();
      }
    });
  }

  clearSearch() {
    searchController.clear();
  }

  buildSearchField() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.greenAccent,
      title: TextFormField(
        controller: searchController,
        // ignore: prefer_const_constructors
        decoration: InputDecoration(
          hintText: "Search for a user",
          filled: false,
          prefixIcon: Icon(Icons.account_box, size: 28.0),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
        child: Center(
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          SvgPicture.asset('assets/images/image2vector.svg',
              height: orientation == Orientation.portrait ? 300.0 : 200.0,
              width: 300.0),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final UserModel user;
  final auth = FirebaseAuth.instance;

  UserResult(this.user);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.greenAccent.withOpacity(0.7),
        child: Column(children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(auth.currentUser!.photoURL!),
              ),
              title: Text(
                user.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.bio,
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Divider(
            height: 2.0,
            color: Colors.black,
          )
        ]));
  }
}

showProfile(BuildContext context, {required String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfilePage(
        profileId: profileId,
      ),
    ),
  );
}