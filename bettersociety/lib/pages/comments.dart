import 'package:bettersociety/pages/home.dart';
import 'package:bettersociety/widgets/main_header.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../widgets/progress_bar.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;

  const Comments({super.key, required this.postId, required this.postOwnerId});

  @override
  _CommentsState createState() => _CommentsState(
        postId: postId,
        postOwnerId: postOwnerId,
      );
}

class _CommentsState extends State<Comments> {
  TextEditingController commentController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final auth = FirebaseAuth.instance;

  _CommentsState({required this.postId, required this.postOwnerId});

  buildComments() {
    return StreamBuilder(
      stream: commentsRef.doc(postId).collection('comments').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        List<Comment> comments = [];
        snapshot.data!.docs.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      },
    );
  }

  addComment() {
    commentsRef.doc(postId).collection('comments').add({
      'username': currentUser!.username,
      'comment': commentController.text,
      'timestamp': timestamp,
      'avatarUrl': auth.currentUser!.photoURL,
      'userId': currentUser!.id,
    });
    bool isNotPostOwner = postOwnerId != currentUser!.id;
    if (isNotPostOwner) {
      feedRef.doc(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentController.text,
        'username': currentUser!.username,
        'userId': currentUser!.id,
        'userProfileImg': auth.currentUser!.photoURL,
        'postId': postId,
        'timestamp': timestamp,
      });
    }

    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        titleText: 'Comments',
        removeBackButton: false,
      ),
      body: Column(children: <Widget>[
        Expanded(child: buildComments()),
        const Divider(),
        ListTile(
          title: TextFormField(
            controller: commentController,
            decoration: const InputDecoration(
              labelText: 'Write a comment...',
            ),
          ),
          trailing: OutlinedButton(
            onPressed: () => addComment(),
            child: const Text('Post'),
          ),
        ),
      ]),
    );
  }
}

class Comment extends StatelessWidget {
  final String username;
  final String userId;
  final String avatarUrl;
  final String comment;
  final Timestamp timestamp;

  const Comment({
    super.key,
    required this.username,
    required this.userId,
    required this.avatarUrl,
    required this.comment,
    required this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      userId: doc['userId'],
      avatarUrl: doc['avatarUrl'],
      comment: doc['comment'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
          ),
          subtitle: Text(username),
        ),
        const Divider(),
      ],
    );
  }
}
