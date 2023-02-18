import 'package:bettersociety/pages/post.dart';
import 'package:bettersociety/pages/search.dart';
import 'package:bettersociety/widgets/progress-bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';
import '../models/user.dart';
import 'home.dart';

class TimelinePage extends StatefulWidget {
  final UserModel? currentUser;

  const TimelinePage({super.key, required this.currentUser});
  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<Post> posts = [];
  List<String> followingList = [];
  final followingRef = FirebaseFirestore.instance.collection('following');

  @override
  void initState() {
    super.initState();
    getTimeline();
    getFollowing();
  }

  void selectedItem(BuildContext context, item) async {
    switch (item) {
      case 0:
        await getTimelineCategory("Cleaning");
        break;
      case 1:
        await getTimelineCategory("Food Preparing");
        break;
      default:
        await getTimelineCategory("Other");
    }
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.currentUser?.id)
        .collection("userFollowing")
        .get();
    setState(() {
      followingList = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  getTimelineCategory(String category) async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser?.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .where(
          "category",
          isEqualTo: category,
        )
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .doc(widget.currentUser?.id)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .where(
          "category",
        )
        .get();
    List<Post> posts =
        snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts.isEmpty) {
      return buildUsersToFollow();
    }
    return ListView(
      children: posts,
    );
  }

  buildUsersToFollow() {
    return StreamBuilder(
      stream: usersRef.limit(30).snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data?.docs.forEach((doc) {
          UserModel user = UserModel.fromDocument(doc);
          final bool isAuthUser = currentUser?.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);

          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user);
            userResults.add(userResult);
          }
        });
        return Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.person_add,
                      color: Colors.black,
                      size: 30.0,
                    ),
                    SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      "Users to Follow",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30.0,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: userResults,
              ),
            ],
          ),
        );
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
                textTheme: const TextTheme().apply(bodyColor: Colors.black),
                dividerColor: Colors.white, 
                iconTheme: const IconThemeData(color: Colors.white)),
            child: PopupMenuButton<int>(
              color: Colors.white,
              itemBuilder: (context) => const [
                PopupMenuItem<int>(value: 0, child: Text("Cleaning")),
                PopupMenuDivider(),
                PopupMenuItem(value: 1, child: Text("Food Preparing")),
                PopupMenuDivider(),
                PopupMenuItem<int>(value: 2, child: Text("Other")),
              ],
              onSelected: (item) => selectedItem(context, item),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        title: Text(
          "Better Society",
          style: GoogleFonts.signika(
            color: Colors.white,
            fontSize: 30.0,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.greenAccent,
      ),
      body: RefreshIndicator(
        onRefresh: () async => await getTimeline(),
        child: buildTimeline(),
      ),
    );
  }
}
