// ignore_for_file: no_logic_in_create_state, library_private_types_in_public_api

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

  const Post({
    super.key,
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
        postId: postId,
        ownerId: ownerId,
        username: username,
        location: location,
        description: description,
        likes: likes,
        likeCount: getLikeCount(likes),
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
  final String? currentUserId = currentUser?.id;
  bool isLiked = false;
  bool isOwner = false;
  int attendanceCount = 0;
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
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(user.photoUrl),
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
            icon: const Icon(Icons.more_vert),
            onPressed: () => handleDelete(context, snapshot),
          ),
        );
      },
    );
  }

  handleDelete(BuildContext parentContext, snapshot) {
    if (currentUserId == ownerId) {
      isOwner = true;
    }
    return isOwner
        ? showDialog(
            context: parentContext,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Remove this post?'),
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      deletePost();
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () async {
                      final data =
                          await Navigator.pushNamed(context, '/scanner');
                      await postsRef
                          .doc(ownerId)
                          .collection('userPosts')
                          .doc(postId)
                          .update({'hasAttended': data});
                      setState(() {
                        attendanceCount = attendanceCount + 1;
                      });
                      usersRef.doc(data as String?).update(
                          {'hasAttended': attendanceCount, 'QRCode': data});
                    },
                    child: const Text(
                      'Scan QR Code',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () async {
                      await Navigator.pushNamed(context, '/user-attend');
                    },
                    child: const Text("See who's attending",
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              );
            },
          )
        : showDialog(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('Report this post?'),
                children: [
                  SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Report',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              );
            },
          );
    ;
  }

  deletePost() async {
    if (currentUserId == ownerId) {
      postsRef.doc(ownerId).collection('posts').doc(postId).delete();
      postsRef.doc(ownerId).collection('userPosts').doc(postId).delete();
      QuerySnapshot activityFeedSnapshot = await feedRef
          .doc(ownerId)
          .collection('feedItems')
          .where('postId', isEqualTo: postId)
          .get();
      for (var doc in activityFeedSnapshot.docs) {
        if (doc.exists) {
          doc.reference.delete();
        }
      }
      QuerySnapshot commentsSnapshot =
          await commentsRef.doc(postId).collection('comments').get();
      for (var doc in commentsSnapshot.docs) {
        if (doc.exists) {
          doc.reference.delete();
        }
      }
    }
    Navigator.pop(context);
  }

  handleLike() {
    bool isLike = likes[currentUserId] == true;

    if (isLike) {
      setState(() {
        likeCount -= 1;
        isLiked = false;
        likes[currentUserId] = false;
        postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
          'likes.$currentUserId': false,
        });
      });
      removeLikeFromActivityFeed();
    } else if (!isLike) {
      postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
        'likes.$currentUserId': true,
      });
      setState(() {
        likeCount += 1;
        isLiked = true;
        likes[currentUserId] = true;
        postsRef.doc(ownerId).collection('userPosts').doc(postId).update({
          'likes.$currentUserId': true,
        });
      });
      addLikeToActivityFeed();
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = currentUserId != ownerId;
    if (isNotPostOwner) {
      feedRef.doc(ownerId).collection('feedItems').doc(postId).set({
        'type': 'like',
        'username': currentUser?.username,
        'userId': currentUser?.id,
        'userProfileImg': auth.currentUser?.photoURL,
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
                child: const Icon(
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
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 5, top: 10),
          child: BottomNavigationBar(
            currentIndex: value == 'Yes'
                ? 0
                : value == 'Maybe'
                    ? 1
                    : value == 'No'
                        ? 2
                        : 0,
            onTap: (value) => setState(() {
              if (value == 0) {
                this.value = 0;
                postsRef
                    .doc(ownerId)
                    .collection('userPosts')
                    .doc(postId)
                    .update({
                  'isAttending.$currentUserId': true,
                });
              } else if (value == 1) {
                this.value == 1;
                postsRef
                    .doc(ownerId)
                    .collection('userPosts')
                    .doc(postId)
                    .update({
                  'isAttending.$currentUserId': false,
                });
              } else if (value == 2) {
                this.value == 2;
                postsRef
                    .doc(ownerId)
                    .collection('userPosts')
                    .doc(postId)
                    .update({
                  'isAttending.$currentUserId': false,
                });
              }
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
          ),
        ),
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
        Divider(
          height: 15,
          thickness: 1,
          color: Colors.grey[300],
        )
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
