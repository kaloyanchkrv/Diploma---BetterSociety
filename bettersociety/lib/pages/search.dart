import 'package:bettersociety/main.dart';
import 'package:bettersociety/models/user.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/progress-bar.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

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
        for (var doc in snapshot.data!.docs) {
          UserModel user = UserModel.fromDocument(doc);
          UserResult searchResult = UserResult(user);
          searchResults.add(searchResult);
        }
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
        decoration: InputDecoration(
          hintText: "Search for a user",
          filled: false,
          prefixIcon: const Icon(Icons.account_box, size: 28.0),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: clearSearch,
          ),
        ),
        onFieldSubmitted: handleSearch,
      ),
    );
  }

  buildNoContent() {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: const <Widget>[
          Icon(
            Icons.search,
            color: Colors.grey,
            size: 200.0,
          ),
          Text(
            "Find Users...",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 40.0,
            ),
          ),
        ],
      ),
    );
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

  UserResult(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.grey[200],
        child: Column(children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              title: Text(
                user.username,
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.bio,
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const Divider(
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
