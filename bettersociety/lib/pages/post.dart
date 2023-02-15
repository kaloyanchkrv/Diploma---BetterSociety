// ignore_for_file: no_logic_in_create_state

import 'package:bettersociety/pages/home.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/user.dart';
import '../widgets/progress-bar.dart';
import 'comments.dart';

class Post extends StatefulWidget {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final dynamic likes;

  Post({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.location,
    required this.description,
    required this.likes,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      likes: doc['likes'],
    );
  }

  int getLikeCount(likes) {
    if (likes == null) {
      return 0;
    }

    int count = 0;
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }

  @override
  _PostState createState() => _PostState(
        postId: this.postId,
        ownerId: this.ownerId,
        username: this.username,
        location: this.location,
        description: this.description,
        likes: this.likes,
        likeCount: getLikeCount(this.likes),
      );
}

class _PostState extends State<Post> {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  Map likes;
  int likeCount;
  final auth = FirebaseAuth.instance;
  int? value;
  final String currentUserId = currentUser!.id;
  bool isLiked = false;
  final postsRef = FirebaseFirestore.instance.collection('posts');

  _PostState(
      {required this.postId,
      required this.ownerId,
      required this.username,
      required this.location,
      required this.description,
      required this.likes,
      required this.likeCount});

  buildPostHeader() {
    return FutureBuilder(
      future: usersRef.doc(ownerId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        UserModel user =
            UserModel.fromDocument(snapshot.data as DocumentSnapshot);
        // bool isPostOwner = currentUserId == ownerId;
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(auth.currentUser!.photoURL!),
            backgroundColor: Colors.grey,
          ),
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
            child: Text(
              user.username,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          subtitle: Text(location),
          trailing: IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () => print('deleting post'),
          ),
        );
      },
    );
  }

  handleLike() {
    bool _isLiked = likes[currentUserId] == true;

    if (_isLiked) {
      postsRef.doc(ownerId).collection('posts').doc(postId).update({
        'likes.$currentUserId': false,
      });
      removeLikeFromActivityFeed();
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
      });
    } else if (!_isLiked) {
      postsRef.doc(ownerId).collection('posts').doc(postId).update({
        'likes.$currentUserId': true,
      });
      addLikeToActivityFeed();
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      feedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        'type': 'like',
        'username': currentUser!.username,
        'userId': currentUser!.id,
        'userProfileImg': auth.currentUser!.photoURL,
        'postId': postId,
        'timestamp': timestamp,
      });
    }
  }

  removeLikeFromActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      feedRef
          .doc(ownerId)
          .collection('feedItems')
          .doc(postId)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostImage() {
    return GestureDetector(
      onDoubleTap: handleLike,
      child: Stack(
        alignment: Alignment.center,
        children: [Text(description)],
      ),
    );
  }

  showComments(BuildContext context,
      {required String postId, required String ownerId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Comments(
          postId: postId,
          postOwnerId: ownerId,
        ),
      ),
    );
  }

  buildPostFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 20.0),
              child: GestureDetector(
                onTap: handleLike,
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 28.0,
                  color: Colors.pink,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 20.0),
              child: GestureDetector(
                onTap: () => showComments(
                  context,
                  postId: postId,
                  ownerId: ownerId,
                ),
                child: Icon(
                  Icons.chat,
                  size: 28.0,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                '$likeCount likes',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Container(
            child: BottomNavigationBar(
          currentIndex: value == 'Yes'
              ? 0
              : value == 'Maybe'
                  ? 1
                  : value == 'No'
                      ? 2
                      : 0,
          onTap: (value) => setState(() {
            this.value = value;
          }),
          items: [
            BottomNavigationBarItem(
              icon: value == 0
                  ? const Icon(Icons.check, color: Colors.green, size: 25)
                  : const Icon(Icons.check, color: Colors.grey, size: 25),
              label: 'Yes',
            ),
            BottomNavigationBarItem(
              icon: value == 1
                  ? const Icon(
                      Icons.question_mark,
                      color: Colors.yellow,
                      size: 25,
                    )
                  : const Icon(
                      Icons.question_mark,
                      color: Colors.grey,
                      size: 25,
                    ),
              label: 'Maybe',
            ),
            BottomNavigationBarItem(
              icon: value == 2
                  ? const Icon(Icons.close, color: Colors.red, size: 25)
                  : const Icon(Icons.close, color: Colors.grey, size: 25),
              label: 'No',
            ),
          ],
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        buildPostHeader(),
        buildPostImage(),
        buildPostFooter(),
      ],
    );
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
