import 'package:bettersociety/main.dart';
import 'package:bettersociety/pages/home.dart';
import 'package:bettersociety/pages/profile.dart';
import 'package:bettersociety/widgets/progress-bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/main-header.dart';
import 'create-account.dart';
import 'package:timeago/timeago.dart' as timeago;

final usersRef = FirebaseFirestore.instance.collection('users');
final FirebaseAuth _auth = FirebaseAuth.instance;

class ActivityFeedPage extends StatefulWidget {
  @override
  _ActivityFeedPageState createState() => _ActivityFeedPageState();
}

class _ActivityFeedPageState extends State<ActivityFeedPage> {
  getActivity() async {
    QuerySnapshot snapshot = await feedRef
        .doc(currentUser!.id)
        .collection('feedItems')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .get();
    List<ActivityFeedItem> feedItems = [];
    snapshot.docs.forEach((doc) {
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItems;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(titleText: "Activity Feed", removeBackButton: true),
        body: Container(
          child: FutureBuilder(
            future: getActivity(),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return Text('kur');
              }
              return ListView(
                children: snapshot.data,
              );
            },
          ),
        ));
  }
}

late String activityItemText;

class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String userId;
  final String type;
  final String postId;
  final String commentData;
  final String userProfileImg;
  final Timestamp timestamp;

  ActivityFeedItem({
    required this.username,
    required this.userId,
    required this.type,
    required this.postId,
    required this.commentData,
    required this.userProfileImg,
    required this.timestamp,
  });

  factory ActivityFeedItem.fromDocument(DocumentSnapshot doc) {
    return ActivityFeedItem(
      username: doc['username'],
      userId: doc['userId'],
      type: doc['type'],
      postId: doc['postId'],
      commentData: doc['commentData'],
      userProfileImg: doc['userProfileImg'],
      timestamp: doc['timestamp'],
    );
  }

  configurePreview() {
    if (type == "like") {
      activityItemText = "liked your post";
    } else if (type == "comment") {
      activityItemText = "replied: $commentData";
    } else if (type == "follow") {
      activityItemText = "is following you";
    } else {
      activityItemText = "Error: Unknown type '$type'";
    }
  }

  @override
  Widget build(BuildContext context) {
    configurePreview();

    return Padding(
      padding: EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.grey[200],
        child: ListTile(
          title: GestureDetector(
            onTap:() => showProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " $activityItemText",
                  ),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(userProfileImg),
          ),
          subtitle: Text(
            timeago.format(timestamp.toDate()),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
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
