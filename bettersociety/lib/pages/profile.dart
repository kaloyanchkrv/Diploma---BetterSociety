import 'package:bettersociety/models/user.dart';
import 'package:bettersociety/pages/post.dart';
import 'package:bettersociety/widgets/progress-bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main.dart';

import 'home.dart';

class ProfilePage extends StatefulWidget {
  final String? profileId;
  const ProfilePage({super.key, this.profileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = FirebaseAuth.instance;
  final String? currentUserId = currentUser?.id;
  final postsRef = FirebaseFirestore.instance.collection('posts');
  final followersRef = FirebaseFirestore.instance.collection('followers');
  final followingRef = FirebaseFirestore.instance.collection('following');
  late String imageUrl = "";
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];
  bool isFollowing = false;
  int followerCount = 0;
  int followingCount = 0;

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    checkIfFollowing();
    getFollowers();
    getFollowing();
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .get();
    List<String> followerList = [];
    for (var doc in snapshot.docs) {
      followerList.add(doc.id);
    }
    setState(() {
      followerCount = followerList.length;
    });
    return followerList;
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .doc(widget.profileId)
        .collection('userFollowing')
        .get();
    List<String> followingList = [];
    for (var doc in snapshot.docs) {
      followingList.add(doc.id);
    }
    setState(() {
      followingCount = followingList.length;
    });
    return followingList;
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot =
        await postsRef.doc(widget.profileId).collection('userPosts').get();
    setState(() {
      isLoading = false;
      postCount = snapshot.docs.length;
      posts = snapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  void selectedItem(BuildContext context, item) {
    switch (item) {
      case 1:
        Navigator.pushNamed(context, '/achievements');
        break;
      case 2:
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
            decoration: isFollowing
                ? BoxDecoration(
                    color: Colors.greenAccent,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(6.0),
                  )
                : BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.greenAccent),
                    borderRadius: BorderRadius.circular(6.0),
                  ),
            child: Text(
              text,
              style: isFollowing
                  ? const TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    )
                  : const TextStyle(
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
    } else if (isFollowing) {
      return buildButton(
        text: "Unfollow",
        func: () => handleUnfollow(),
      );
    } else if (!isFollowing) {
      return buildButton(
        text: "Follow",
        func: () => handleFollow(),
      );
    }
  }

  handleUnfollow() {
    setState(() {
      isFollowing = false;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    feedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleFollow() {
    setState(() {
      isFollowing = true;
    });

    followersRef
        .doc(widget.profileId)
        .collection('userFollowers')
        .doc(currentUserId)
        .set({});

    followingRef
        .doc(currentUserId)
        .collection('userFollowing')
        .doc(widget.profileId)
        .set({});

    feedRef
        .doc(widget.profileId)
        .collection('feedItems')
        .doc(currentUserId)
        .set({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser?.username ?? "",
      'userId': currentUserId,
      'userProfileImg': auth.currentUser?.photoURL ?? "",
      'timestamp': DateTime.now(),
      'postId': '',
      'commentData': '',
    });
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
          margin: const EdgeInsets.only(top: 4.0),
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
          const Divider(),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    GestureDetector(
                        child: auth.currentUser?.photoURL == ""
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
                                backgroundImage: NetworkImage(
                                    auth.currentUser?.photoURL ?? ""),
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
                              buildCount("followers", followerCount),
                              buildCount("following", followingCount),
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
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    user.bio,
                    style: const TextStyle(
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
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
                textTheme: const TextTheme().apply(bodyColor: Colors.black),
                dividerColor: Colors.white,
                iconTheme: const IconThemeData(color: Colors.white)),
            child: PopupMenuButton<int>(
              color: Colors.white,
              itemBuilder: (context) => [
                const PopupMenuItem<int>(value: 0, child: Text("Achievements")),
                const PopupMenuDivider(),
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
              onSelected: (item) => selectedItem(context, item),
            ),
          ),
        ],
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
        const Divider(
          height: 0.0,
        ),
        buildProfilePosts(),
      ]),
    );
  }
}
